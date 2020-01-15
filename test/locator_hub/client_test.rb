require 'test_helper'
require 'ndr_lookup/locator_hub/client'

module NdrLookup
  module LocatorHub
    # ArcGIS LocatorHub API client tests
    class ClientTest < Minitest::Test
      def test_should_raise_exception_on_missing_credentials
        assert_nil NdrLookup::LocatorHub::Client.domain
        assert_nil NdrLookup::LocatorHub::Client.username
        assert_nil NdrLookup::LocatorHub::Client.password

        assert_raises do
          NdrLookup::LocatorHub::Client.new('https://::1/LocatorHub/Rest')
        end
      end

      def test_should_match_address_and_return_an_array_of_matched_records
        configure_client do
          stub_locator_id do
            api = NdrLookup::LocatorHub::Client.new('https://example.com/LocatorHub/Rest')

            first_child_query  = 'Cambridge%20Road,%20Fulbourn,%20Cambridgeshire,%20CB21'
            second_child_query = 'Capital%20Park,%20Fulbourn,%20Cambridge,%20CB21%205XA'
            uni_query          = 'Anglia%20Ruskin%20University,%20Faculty%20Of%20Health%20And%20Social%20Care,%20Victoria%20House,%20Cambridge%20Road,%20Fulbourn,%20Cambridgeshire,%20CB21%205XA'
            nhs_query          = 'Nhs%20England,%20West%20Wing%20Victoria%20House,%20Capital%20Park,%20Cambridge%20Road,%20Fulbourn,%20Cambridgeshire,%20CB21%205XA'

            match_url        = url_to_stub(nil, nil, 'CB21+5XA')
            first_child_url  = url_to_stub('example_cache_one', '1', first_child_query)
            second_child_url = url_to_stub('example_cache_one', '2', second_child_query)
            uni_url          = url_to_stub('example_cache_two', '1', uni_query)
            nhs_url          = url_to_stub('example_cache_two', '2', nhs_query)

            stub_request(:any, match_url).to_return(body: stub_address_file('with_children'))
            stub_request(:any, first_child_url).to_return(body: stub_address_file('first_child'))
            stub_request(:any, uni_url).to_return(body: stub_address_file('second_child'))
            stub_request(:any, nhs_url).to_return(body: stub_address_file('uni'))
            stub_request(:any, second_child_url).to_return(body: stub_address_file('nhs'))

            # Should be array of MatchedRecord responses
            response = api.match_address('CB21 5XA')
            assert_kind_of(Array, response)

            response.each do |record|
              assert_kind_of(NdrLookup::LocatorHub::MatchedRecord, record)
            end
          end
        end
      end

      private

      def stub_address_file(name)
        File.new(RESPONSES_DIR + "/locator_hub/address_match_#{name}_success.json")
      end

      def url_to_stub(cacheid, pickeditem, query)
        "https://example.com/LocatorHub/Rest/Match/example-locator/ADDRESS?Cacheid=#{cacheid}&Fuzzy=false&Pickeditem=#{pickeditem}&Query=#{query}&ReturnCoordinateSystem=-1&format=json"
      end

      def configure_client
        NdrLookup::LocatorHub::Client.domain   = 'domain'
        NdrLookup::LocatorHub::Client.username = 'username'
        NdrLookup::LocatorHub::Client.password = 'password'

        yield if block_given?

      ensure
        NdrLookup::LocatorHub::Client.domain   = nil
        NdrLookup::LocatorHub::Client.username = nil
        NdrLookup::LocatorHub::Client.password = nil
      end

      def stub_locator_id
        locators_url = 'https://example.com/LocatorHub/Rest/listlocators?format=json'
        stub_request(:any, locators_url).to_return(body: File.new(RESPONSES_DIR + '/locator_hub/locators.json'))

        yield if block_given?
      end
    end
  end
end
