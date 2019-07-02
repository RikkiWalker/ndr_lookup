require 'test_helper'
require 'ndr_lookup/nhsd_ods/code_systems'

module NdrLookup
  module NhsdOds
    # The recordclass class tests
    class RecordclassTest < Minitest::Test
      def test_recordclass_should_respond_to_all
        url  = ODS_ENDPOINT + 'recordclasses'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/recordclass_all_success_response.txt')
        stub_request(:get, url).to_return(file)
        record_classes = NdrLookup::NhsdOds::Recordclass.all

        assert_equal record_classes.count, 2
      end

      def test_recordclass_should_respond_to_first
        url  = ODS_ENDPOINT + 'recordclasses'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/recordclass_all_success_response.txt')
        stub_request(:get, url).to_return(file)
        record_class = NdrLookup::NhsdOds::Recordclass.first

        assert_equal record_class.id, 'RC1'
      end

      def test_recordclass_should_respond_to_find
        url  = ODS_ENDPOINT + 'recordclasses/RC2'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/recordclass_find_success_response.txt')
        stub_request(:get, url).to_return(file)
        record_class = NdrLookup::NhsdOds::Recordclass.find('RC2')

        assert_equal record_class.id, 'RC2'
      end

      def test_recordclass_should_raise_error_if_not_found
        url  = ODS_ENDPOINT + 'recordclasses/RC3'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/metadata_not_found_response.txt')
        stub_request(:get, url).to_return(file)

        assert_raises do
          NdrLookup::NhsdOds::Recordclass.find('RC3')
        end
      end
    end

    # The rel class tests
    class RelTest < Minitest::Test
      def test_rel_should_respond_to_all
        url  = ODS_ENDPOINT + 'rels'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/rel_all_success_response.txt')
        stub_request(:get, url).to_return(file)
        record_classes = NdrLookup::NhsdOds::Rel.all

        assert_equal record_classes.count, 5
      end

      def test_rel_should_respond_to_first
        url  = ODS_ENDPOINT + 'rels'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/rel_all_success_response.txt')
        stub_request(:get, url).to_return(file)
        record_class = NdrLookup::NhsdOds::Rel.first

        assert_equal record_class.id, 'RE3'
      end

      def test_rel_should_respond_to_find
        url  = ODS_ENDPOINT + 'rels/RE6'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/rel_find_success_response.txt')
        stub_request(:get, url).to_return(file)
        record_class = NdrLookup::NhsdOds::Rel.find('RE6')

        assert_equal record_class.id, 'RE6'
      end

      def test_rel_should_raise_error_if_not_found
        url  = ODS_ENDPOINT + 'rels/Wrong'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/metadata_not_found_response.txt')
        stub_request(:get, url).to_return(file)

        assert_raises do
          NdrLookup::NhsdOds::Rel.find('Wrong')
        end
      end
    end

    # The role class tests
    class RoleTest < Minitest::Test
      def test_role_should_respond_to_all
        url  = ODS_ENDPOINT + 'roles'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/role_all_success_response.txt')
        stub_request(:get, url).to_return(file)
        record_classes = NdrLookup::NhsdOds::Role.all

        assert_equal record_classes.count, 137
      end

      def test_role_should_respond_to_first
        url  = ODS_ENDPOINT + 'roles'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/role_all_success_response.txt')
        stub_request(:get, url).to_return(file)
        record_class = NdrLookup::NhsdOds::Role.first

        assert_equal record_class.id, 'RO180'
      end

      def test_role_should_respond_to_find
        url  = ODS_ENDPOINT + 'roles/RO98'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/role_find_success_response.txt')
        stub_request(:get, url).to_return(file)
        record_class = NdrLookup::NhsdOds::Role.find('RO98')

        assert_equal record_class.id, 'RO98'
      end

      def test_role_should_raise_error_if_not_found
        url  = ODS_ENDPOINT + 'roles/Wrong'
        file = File.new(RESPONSES_DIR + '/nhsd_ods/metadata_not_found_response.txt')
        stub_request(:get, url).to_return(file)

        assert_raises do
          NdrLookup::NhsdOds::Role.find('Wrong')
        end
      end
    end
  end
end
