RAILS_ENV = 'test'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment'))

require 'rubygems'
require 'test/unit'
require 'yaml'

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/porterable'))

class Test::Unit::TestCase
  
  fixtures :all
  
  def sample_csv_path
    File.expand_path(File.join(File.dirname(__FILE__), '../samples/sample.csv'))
  end
  
end

require File.dirname(__FILE__) + '/../init.rb'
require File.dirname(__FILE__) + '/../samples/sample_template.rb'


class Address < ActiveRecord::Base
  
  def to_s
    %{#{address1}
      #{address2}
      #{city}, #{state} #{postal}
      #{country}}
  end
end

class User < ActiveRecord::Base
  belongs_to :billing_address, :class_name => "Address", :foreign_key => "billing_address_id"
  belongs_to :primary_address, :class_name => "Address", :foreign_key => "primary_address_id"
  
  is_porterable
  
  def display_name
    "#{first_name} #{last_name}"
  end
end

class Admin < User; end;

class String
  def header_row
    self.split('\n').first
  end
end
