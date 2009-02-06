require File.join(File.dirname(__FILE__), "lib/porterable.rb")
ActiveRecord::Base.send(:include, Porterable::IsPorterable)