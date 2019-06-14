require 'active_resource'
require 'active_support'
require 'active_support/core_ext'
require 'httpi'
require 'json'

module NdrLookup
  module NhsdOds
    # The API Client for hitting the sync and search endpoints
    class Client
      ENDPOINT = 'https://directory.spineservices.nhs.uk/ORD/2-0-0/'.freeze

      class << self
        def sync(date)
          date = date.to_date
          raise ArgumentError, 'invalid date' unless date.is_a?(Date)

          request  = ENDPOINT + 'sync?LastChangeDate=' + date.strftime('%F')
          response = HTTPI.get(request)
          payload  = JSON.parse(response.body)

          raise_unless_response_success(response, payload)

          payload['Organisations']
        end

        def search(params = {})
          # Expecting the keys to be valid query parameters
          # https://digital.nhs.uk/services/organisation-data-service/guidance-for-developers/search-endpoint#parameters
          query    = HTTPI::QueryBuilder::Flat.build(params)
          request  = ENDPOINT + 'organisations?' + query
          response = HTTPI.get(request)
          payload  = JSON.parse(response.body)

          raise_unless_response_success(response, payload)

          payload['Organisations']
        end

        private

        def raise_unless_response_success(response, payload)
          raise "#{payload['errorCode']} - #{payload['errorText']}" unless response.code == 200
        end
      end
    end
  end
end
