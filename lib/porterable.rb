require 'rubygems'
require 'fastercsv'

%w{is_porterable controller template extensions}.each do |filename|
  require File.join(File.dirname(__FILE__), "/porterable/#{filename}.rb")
end

module Porterable

  def self.export_filename(prefix = nil)
    "#{prefix}_export-" + Time.now.strftime("%Y%m%d-%H%M%S") + ".csv"
  end

  def self.export_content_type(user_agent = nil)
    if user_agent =~ /windows/i
      'application/vnd.ms-excel'
    else
      'text/csv'
    end
  end

end