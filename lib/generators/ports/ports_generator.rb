class PortsGenerator < Rails::Generator::NamedBase
  
  def manifest
    record do |m|
      m.directory(File.join('app/models'))
      m.directory(File.join('app/views','shared'))
      m.directory(File.join('db/migrate'))

      # Controller templates
      %w(ports import scan).each do |action|
        m.template "#{action}.rhtml", File.join('app', 'views', 'shared', "#{action}.html.erb")
      end

      m.template('model.rb', File.join('app/models', "port.rb"))
      m.template('sub_model.rb', File.join('app/models', "#{file_name}_port.rb"))

      m.migration_template('migration.rb', 'db/migrate', :assigns => { :migration_name => "CreatePorts"  }, :migration_file_name => "create_ports")

    end
  end

  protected
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} ports"
  end

end