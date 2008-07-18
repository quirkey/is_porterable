class Port < ActiveRecord::Base

  is_sorterable
  
  class << self
    def import(data, test_run = false, reconcile = true)
      port_data = port_klass.update_from_csv(data,self.last_export_time, test_run, reconcile)
      unless test_run
        self.create(port_data.update(:im_or_ex => 'im')) 
      else
        port_data
      end
    end

    def export(options = {})
      csv_data = port_klass.to_csv(options)
      self.create(:im_or_ex => 'ex',:data => csv_data)
      csv_data
    end

    def export_filename(prefix = nil)
      prefix ||= port_klass_name.downcase
      "#{prefix}_export-" + Time.now.strftime("%Y%m%d-%H%M%S") + ".csv"
    end

    def content_type(user_agent = nil)
      if user_agent =~ /windows/i
        'application/vnd.ms-excel'
      else
        'text/csv'
      end
    end
    
    def port_klass_name
      self.to_s.gsub(/port/i, '')
    end
    
    def port_klass
      port_klass_name.constantize
    end

    def last_export_time
      port = find(:first, :conditions => ["im_or_ex = ?","ex"], :order => "created_at DESC")
      port ? port.created_at : Time.now
    end
  end

end
