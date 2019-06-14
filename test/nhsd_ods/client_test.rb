require 'test_helper'
require 'active_support/core_ext/time'
require 'ndr_lookup/nhsd_ods/client'

module NdrLookup
  module NhsdOds
    # NHS Digital API client test
    class ClientTest < Minitest::Test
      def test_should_return_valid_sync_from_file
        url  = ODS_ENDPOINT + "sync?LastChangeDate=#{Date.current}"
        file = File.new(RESPONSES_DIR + '/nhsd_ods/sync_success_response.txt')
        stub_request(:get, url).to_return(file)
        response = NdrLookup::NhsdOds::Client.sync(Date.current)

        assert_kind_of(Array, response)
      end

      def test_sync_should_raise_error_on_wrong_date_type
        assert_raises(ArgumentError) do
          NdrLookup::NhsdOds::Client.sync('nhs')
        end
      end

      def test_should_return_valid_search
        url  = ODS_ENDPOINT + 'organisations?Name=nhs'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/search_success_response.txt')
        stub_request(:get, url).to_return(file)
        response = NdrLookup::NhsdOds::Client.search(Name: 'nhs')

        assert_kind_of(Array, response)
      end

      def test_search_should_raise_error_on_wrong_param_names
        url  = ODS_ENDPOINT + 'organisations?wrong_param=nhs'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/search_not_acceptable_response.txt')
        stub_request(:get, url).to_return(file)

        assert_raises do
          NdrLookup::NhsdOds::Client.search(wrong_param: 'nhs')
        end
      end
    end
  end
end
