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
    end
  end
end
