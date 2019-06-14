require 'active_support'
require 'active_resource'
require_relative 'client'

module NdrLookup
  module NhsdOds
    # The orgaisation class to allow organisation to work like you would expect a model to work
    # The API only supports .find <code>
    class Organisation < ActiveResource::Base
      self.include_format_in_path = false
      self.site = Client::ENDPOINT

      def initialize(attributes, persisted = false)
        attributes.deep_transform_keys!(&:downcase)
        super(attributes, persisted)
      end

      private

      def const_valid?(*const_args)
        return false if const_args.first == 'Date'

        super(*const_args)
      end
    end
  end
end
