require 'active_support'
require 'active_resource'
require_relative 'client'

module NdrLookup
  module NhsdOds
    # Retrieve CodeSystems information for NHS Digital ODS meta data.
    class CodeSystems < ActiveResource::Base
      self.include_format_in_path = false
      self.site = Client::ENDPOINT

      def initialize(attributes, persisted = false)
        attributes = attributes.first if attributes.is_a? Array
        attributes.deep_transform_keys!(&:downcase)
        super(attributes, persisted)
      end
    end

    # Retrieve CodeSystems information for Record class meta data.
    class Recordclass < CodeSystems
    end

    # Retrieve CodeSystems information for Relationships meta data.
    class Rel < CodeSystems
    end

    # Retrieve CodeSystems information for Roles meta data.
    class Role < CodeSystems
    end
  end
end
