require 'active_support/core_ext/module'
require 'net/http'
require 'rubyntlm'
require 'httpi'
require 'json'
require_relative 'matched_record'

module NdrLookup
  module LocatorHub
    # This class is the LocatorHub API client
    class Client
      LIST_LOCATORS_PATH = 'listlocators?format=json'.freeze

      LOCATOR_ID = 'LocatorId'.freeze
      LOCATOR_NAME = 'LocatorName'.freeze

      ADDRESS_BASE_PREMIUM_WA = 'AddressBasePremiumWA'.freeze

      # The authenticating domain credentials of the API,
      # all of which must be configured by the host app
      cattr_accessor :domain, :password, :username
      self.domain = nil
      self.password = nil
      self.username = nil

      def initialize(api_path)
        check_credentials
        @api_path = api_path
      end

      def locator_id
        @locator_id ||= locator[LOCATOR_ID]
      end

      def rectify_address(address)
        query    = build_query(address)
        response = call_postcode_service("Rectify/#{locator_id}/ADDRESS?#{query}")
        MatchedRecord.new(response)
      end

      def match_address(query)
        get_matches(query: query, target: 'ADDRESS')
      end

      # def capabilities
      #   call_postcode_service("Capabilities/#{locator_id}?format=json")
      # end

      private

      def listlocators
        call_postcode_service(LIST_LOCATORS_PATH)
      end

      def locator
        listlocators.find { |l| l[LOCATOR_NAME] == ADDRESS_BASE_PREMIUM_WA }
      end

      def request
        @request ||= begin
          HTTPI.adapter = :net_http
          request = HTTPI::Request.new
          request.auth.ntlm(username, password, domain)
          request
        end
      end

      def call_postcode_service(path)
        request.url = [@api_path, path].join('/')
        response = HTTPI.get(request, :net_http)
        JSON.parse(response.body)
      end

      def check_credentials
        unset_attributes = %i[domain password username].select { |attr| send(attr).nil? }
        return if unset_attributes.empty?

        raise "NdrLookup::LocatorHub::Client attributes #{unset_attributes.join(', ')} " \
              'have not been configured'
      end

      def get_matches(query:, target:, fuzzy: false, cacheid: '', pickeditem: '')
        query    = build_query(query, fuzzy, cacheid, pickeditem)
        response = call_postcode_service("Match/#{locator_id}/#{target}?#{query}")

        if response['PickListItems']
          cache_id = response['CacheIdentifier']

          response['PickListItems'].flat_map do |record|
            get_matches(query: record['Description'],
                        target: target,
                        cacheid: cache_id,
                        pickeditem: record['RecordId'])
          end
        else
          [MatchedRecord.new(response)]
        end
      end

      def build_query(query, fuzzy = false, cacheid = nil, pickeditem = nil)
        # This is just building a string query for the params on a request
        # format is not caps so its on the end of the query
        # query is sorted alphabetically with caps all before lower case
        URI.encode_www_form(
          Query: query,
          Fuzzy: fuzzy,
          ReturnCoordinateSystem: '-1',
          Pickeditem: pickeditem,
          Cacheid: cacheid,
          format: 'json'
        )
      end
    end
  end
end
