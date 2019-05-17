namespace :locator_hub do
  desc 'setup'
  task :setup do
    require 'highline/import'
    require 'ndr_lookup/locator_hub/client'

    NdrLookup::LocatorHub::Client.domain = ask('Domain name: ')
    NdrLookup::LocatorHub::Client.username = ask('Domain Username: ')
    NdrLookup::LocatorHub::Client.password = ask('Domain Password: ') { |q| q.echo = false }

    @api_path = ask('API Path: ')
  end

  desc 'locator'
  task locator: :setup do
    HTTPI.log = false
    # HTTPI.log_level = :warn

    klass = Address
    max_id = klass.where('udprn is not null').maximum(:id)
    puts max_id
    total_count = klass.where('udprn is not null').count

    LocatorHub::Queue.new(@api_path, klass, max_id, total_count)
  end

  desc 'rectify_address'
  task rectify_address: :setup do
    # Usage: bundle exec rake locator_hub:rectify_address

    address = ask('Address: ')

    client = NdrLookup::LocatorHub::Client.new(@api_path)
    matched_record = client.rectify_address(address)
    puts matched_record.inspect
  end
end
