require_relative 'client'

module NdrLookup
  module LocatorHub
    # Thread queue
    class Queue
      BATCH_SIZE = 100

      def initialize(api_path, klass, max_id, total_count)
        @api_path = api_path
        @klass = klass
        @max_id = max_id
        @total_count = total_count
        @max_worker_count = 8
        @worker_count = 1

        queue_records

        # @threads = [record_getter, max_rate_limiter, rate_limiter, record_setter, monitor]
        @threads = [record_getter, record_setter]

        t0 = Time.current
        @max_worker_count.times { |i| @threads << worker(i) }

        @threads.map(&:join)
        Rails.logger.info "Total Time taken: #{Time.current - t0} secs"
        Rails.logger.info "Time taken (per address): #{(Time.current - t0) / BATCH_SIZE} secs"
      end

      private

      # Pretty form of address field.
      def print_full_address(object)
        "#{object.address&.gsub(/,/, ', ')&.titleize}, " \
        "#{object.postcode&.postcodeize}"
      end

      def input_queue
        @input_queue ||= ::Queue.new
      end

      def output_queue
        @output_queue ||= ::Queue.new
      end

      def worker(i)
        looping_thread("worker #{i}", 120) do
          connect_client do |locator_hub|
            while (i + 1) > @worker_count
              sleep 10
              raise ThreadError if @worker_count.zero?
            end
            raise ThreadError if @worker_count.zero?

            rec = input_queue.pop(true)
            next if rec.address.blank? && rec.postcode.blank?
            result = locator_hub.rectify_address(print_full_address(rec))
            next unless result.postcode == rec.postcode

            lcs_percent = lcs_commonality_percentage(print_full_address(rec),
                                                     result.locator_description)

            if result.score >= 85 || (result.score >= 70 && lcs_percent >= 80)
              rec.udprn = result.udprn if result.udprn.present?
              next unless rec.changed? && rec.valid?

              output_queue.push(rec)
            else
              # rubocop:disable Rails/Output
              puts
              puts "locator_description: #{result.locator_description.inspect}"
              debug_scores(rec, result, lcs_percent)

              lcs_percent2 = lcs_commonality_percentage(
                print_full_address(rec),
                result.locator_description_with_administrative_area
              )
              if lcs_percent2 != lcs_percent
                puts 'locator_description_with_administrative_area: ' +
                     result.locator_description_with_administrative_area.inspect
                debug_scores(rec, result, lcs_percent2)
                # rubocop:enable Rails/Output
              end
              # require 'pry'; binding.pry
            end
          end # connect_client

          Rails.logger.info 'Sleeping...'
        end # looping_thread
      end

      def debug_scores(rec, result, lcs_percent)
        # rubocop:disable Rails/Output
        puts rec.id
        puts print_full_address(rec)
        puts "Match Score: #{result.score}"
        puts "LCS: #{lcs_percent}%"
        # rubocop:enable Rails/Output
      end

      # This method connects to LocatorHub, yields the connection and handles exceptions.
      # It will supress everything except database and thread exceptions.
      def connect_client
        raise(ArgumentError, 'block required') unless block_given?

        client = LocatorHub::Client.new(@api_path)
        loop do
          yield(client)
        end
      rescue OCIError, ThreadError => e
        raise e
      rescue StandardError => e
        Rails.logger.info e.inspect
      end

      def looping_thread(name, sleep_duration)
        Thread.new do
          loop do
            raise ThreadError if @worker_count.zero?

            yield

            sleep sleep_duration
          end
        rescue ThreadError
          Rails.logger.info "#{name} thread finished!"
        end
      end

      def monitor
        @monitor ||= looping_thread('monitor', 1) do
          Rails.logger.info "input_queue: #{input_queue.length} " \
                            "output_queue: #{output_queue.length}"
        end
      end

      def record_getter
        @record_getter ||= looping_thread('record_getter', 1) do
          queue_records if input_queue.length < 25

          raise ThreadError if input_queue.empty?
        end
      end

      def record_setter
        @record_setter ||= looping_thread('record_setter', 1) do
          persist_records if output_queue.length > BATCH_SIZE

          raise ThreadError if input_queue.empty? && output_queue.empty?
        end
      end

      def weekday?
        (1..5).cover?(Time.current.wday)
      end

      def max_rate_limiter
        @max_rate_limiter ||= looping_thread('max_rate_limiter', 10) do
          @max_worker_count = ask('Max Threads: ').to_i
        end
      end

      def rate_limiter
        @rate_limiter ||= looping_thread('rate_limiter', 60) do
          @worker_count = weekday? && (8..15).cover?(Time.current.hour) ? 2 : 10
          @worker_count = @max_worker_count if @max_worker_count < @worker_count
        end
      end

      def lcs_commonality_percentage(a, b)
        squashed_a = a.upcase.gsub(/[,\.\s]+/, '')
        squashed_b = b.upcase.gsub(/[,\.\s]+/, '')
        shorter_length = [squashed_a, squashed_b].map(&:length).min

        lcs = Diff::LCS.lcs(squashed_a, squashed_b)
        100.0 * lcs.length / shorter_length
      end

      def queue_records
        # Rails.logger.info "pushing #{BATCH_SIZE} records onto the queue"
        records = get_records_below_id(@max_id, BATCH_SIZE)
        records.each { |record| input_queue.push(record) }
      end

      def get_records_below_id(id, limit = BATCH_SIZE)
        # find_in_batches ignores order
        # records = Address.includes(:patient).where(udprn: nil).
        records = @klass.where(udprn: nil).
                  where("#{@klass.primary_key} < ?", id).
                  order("#{@klass.primary_key} desc").
                  limit(limit)
        @max_id = records.last.id
        records
      end

      def persist_records
        Rails.logger.info 'persist_records'
        @klass.transaction do
          change_count = 0

          output_queue.length.times do
            rec = output_queue.pop(true)

            # # next unless rec.changed? && rec.valid?
            # # Rails.logger.info "CHANGES: #{rec.changes.inspect}"
            next unless rec.save
            change_count += 1
            @total_count += 1
          end
          # rubocop:disable Rails/Output
          puts "Change count: #{change_count} (Total: #{@total_count})" \
               " Last id: #{@max_id}"
          puts "worker_count: #{@worker_count} max_worker_count: #{@max_worker_count}"
          # rubocop:enable Rails/Output
        end
      end
    end
  end
end
