module Porterable
  module Controller

    def self.included(other_mod)
      klass_name = other_mod.to_s.gsub(/Controller/,'').singularize
      klass = klass_name.constantize
      port_klass = "#{klass_name}Port".constantize


      other_mod.module_eval <<-EOT
      helper_method :controller_name

      def ports
        Port.with_sort(current_sort) do
          @ports = #{port_klass}.paginate :order => "created_at DESC", :page => params[:page]
        end
        render :template => 'shared/ports'
      end

      def import
        @port = #{port_klass}.new
        render :template => 'shared/import'
      end

      def scan
        redirect_to :action => 'import' and return unless request.post?
        @reconcile = params[:import_type].to_i == 1 ? true : false 
        csv_data = params[:import][:file_data].read
        @filename = "csv_data_#{Time.now.to_i}_#{rand(1000)}"
        File.open(File.join(RAILS_ROOT,'tmp',@filename),'w') do |f|
          f << csv_data
        end
        @port = #{port_klass}.import(csv_data, true, @reconcile)
        render :template => 'shared/scan'
      end

      def execute
        redirect_to :action => 'import' and return unless request.post?
        @port = #{port_klass}.import(File.open(File.join(RAILS_ROOT,'tmp',params[:filename]),'r') {|f| f.read }, false, params[:reconcile].to_i == 1 ? true : false )
        flash[:message] = 'File Import Successful.'
        redirect_to :action => 'ports'
      end

      def export
        send_data(#{port_klass}.export, :type => #{port_klass}.content_type(request.user_agent),:filename => #{port_klass}.export_filename)
      end

      EOT
    end

  end
end