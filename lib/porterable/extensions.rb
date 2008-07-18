if defined?(ActionController)
  module ActionController::Resources
    def porterable_resources(entities, &block)
      porterable_actions = {:collection => {:ports => :get, :import => :get, :scan => :any, :export => :get, :execute => :any}}
      puts entities.inspect
      with_options(porterable_actions) { resources(*entities, &block) }
    end
  end
end