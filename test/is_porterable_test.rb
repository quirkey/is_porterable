require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class IsPorterableTest < Test::Unit::TestCase

  def test_a_porterable_model_should_export_all_attributes_to_csv
    csv = User.to_csv
    assert csv.is_a?(String)
    header_row = csv.header_row
    User.column_names.each do |column|
      assert_match(/#{column}/,header_row)
    end
  end

  def test_a_porterable_model_with_exclude_should_not_include_columns
    User.is_porterable :exclude => [:last_name]
    assert User.exclude_columns.include?(:last_name)
    csv = User.to_csv
    assert csv.is_a?(String)
    header_row = csv.header_row
    assert_match(/first_name,/,header_row)
    assert_match(/Aaron/, csv)
    assert_no_match(/last_name/, header_row)
    assert_no_match(/Quint/, csv)
  end

  def test_a_porterable_model_with_export_should_include_methods
    User.is_porterable :export => [:display_name]
    assert User.export_methods.include?(:display_name)
    csv = User.to_csv
    assert csv.is_a?(String)
    header_row = csv.header_row
    assert_match(/display_name/,header_row)
    assert_match(/Aaron Quint/,csv)
  end

  def test_a_porterable_model_should_include_associations
    User.is_porterable :include => [:billing_address]
    assert User.include_associations.include?(:billing_address)
    csv = User.to_csv
    assert csv.is_a?(String)
    header_row = csv.header_row
    assert_match(/billing_address_name/,header_row)
    assert_match(/#{Address.find(:first).to_s}/,csv)
  end
  
  def test_a_porterable_model_with_csv_options_should_use_options_for_that_run_only
  end

end