module NdrLookup
  module LocatorHub
    # This class wraps the client response, creating a hash of matched record
    # columns and provides custom getter methods for cleaning/casting specific columns
    class MatchedRecord
      RECTIFY_RECORD_SCORE = 'RectifyRecordScore'.freeze
      MATCHED_RECORD = 'MatchedRecord'.freeze
      COLUMNS = 'Columns'.freeze
      N = 'N'.freeze
      R = 'R'.freeze

      LOCATOR_DESCRIPTION = 'LOCATOR_DESCRIPTION'.freeze
      ADMINISTRATIVE_AREA = 'ADMINISTRATIVE_AREA'.freeze
      POSTCODE = 'POSTCODE'.freeze
      UDPRN = 'DPA_UDPRN'.freeze

      attr_reader :score

      def initialize(response)
        @score = response[RECTIFY_RECORD_SCORE]
        @record = response[MATCHED_RECORD]
      end

      def locator_description
        @locator_description ||= columns[LOCATOR_DESCRIPTION].
                                 gsub(/\|LOCATOR_SEPARATOR\|/, ', ')
      end

      def administrative_area
        @administrative_area ||= columns[ADMINISTRATIVE_AREA]
      end

      def locator_description_with_administrative_area
        return locator_description if locator_description.include?(administrative_area)

        parts = locator_description.split(', ')
        (parts[0..-2] << administrative_area << parts[-1]).join(', ')
      end

      def postcode
        @postcode ||= columns[POSTCODE].clean(:postcode)
      end

      def udprn
        @udprn ||= columns[UDPRN] == columns[UDPRN].to_i.to_s ? columns[UDPRN].to_i : columns[UDPRN]
      end

      # keys are returned in response['MatchedRecord']['Columns']['N'] and values are returned
      # in response['MatchedRecord']['Columns']['R'] and we turn them back into a normal hash
      def columns
        @columns ||= begin
          columns = {}
          @record && @record[COLUMNS].each.with_index do |column, i|
            columns[column[N]] = @record[R][i]
          end
          columns
        end
      end
    end
  end
end
