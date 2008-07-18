require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class TemplateTest < Test::Unit::TestCase
  
  class TestTemplate < Quirkey::Porterable::Template
    set_map 'first_name', 'last_name', ['billing_address_address_1', 'billing_address.address_1']
  end
  
  
  def test_should_set_map_on_a_class_level
    assert_equal map, TestTemplate.map
  end

  def test_setting_map_should_set_column_names
    assert_equal ['first_name','last_name','billing_address_address_1'], TestTemplate.column_names
  end

  def test_setting_map_and_then_instantiating_should_retain_map
    @template = TestTemplate.new
    assert_equal TestTemplate.column_names, @template.column_names
  end

  protected
  def map(fields = [])
    ['first_name', 'last_name', ['billing_address_address_1', 'billing_address.address_1']].concat(fields)
  end
end