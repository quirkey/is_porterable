module Quirkey
  module Porterable
    module IsPorterable
      def self.included(klass)
        klass.extend MacroMethods
      end

      module MacroMethods
        def is_porterable(options = {})
          @template_class       = options[:template] || nil
          @exclude_columns      = options[:exclude] || []
          @export_methods       = options[:export] || []
          @include_associations = options[:include] || []
          @unique_field         = options[:unique] || :id

          # add name and remove id for included associations
          @include_associations.each do |association|
            @exclude_columns << "#{association}_id".to_sym
            @export_methods << "#{association}_name".to_sym
          end

          extend Quirkey::Porterable::IsPorterable::ClassMethods
          include Quirkey::Porterable::IsPorterable::InstanceMethods
        end

      end

      module ClassMethods
        attr_reader :exclude_columns, :export_methods, :unique_field, :include_associations, :template_class

        def porterable_column_names
          template_class ? template_class.column_names : self.column_names
        end

        def to_csv(options = {})
          find_options = options[:find] || {}
          not_columns = self.exclude_columns
          csv_data = FasterCSV.generate do |csv|
            columns = self.porterable_column_names
            columns.reject! {|c| not_columns.include?(c.to_sym) }
            columns_names = columns | self.export_methods.collect(&:to_s)
            csv << columns_names
            self.find(:all, find_options).each do |row|
              column_values = columns.collect {|c| row.value_for_column(c) }
              self.export_methods.each do |meth|
                column_values << row.send(meth)
              end
              csv << column_values
            end
          end
          csv_data
        end

        def load_csv_str(data)
          input = FasterCSV.parse(data)
          data = []
          keys = input.shift
          input.each do |row|
            row_data = {}
            keys.each_with_index do |key,i|
              row_data[key.strip] = row[i]
            end
            data << row_data
          end
          data
        end

        def update_from_csv(data,only_before = Time.now, test_run = false, reconcile = true)
          port = {}
          csv_data = self.load_csv_str(data)
          #partition to new rows and old rows
          new_rows, old_rows = csv_data.partition {|row| row['id'].nil? }
          #update and delete
          db = self.find(:all,:conditions => ["created_at < ? ",only_before])
          port[:data] = data
          port[:rows_updated] = 0
          port[:rows_deleted] = 0
          port[:rows_added]   = 0
          db.each do |contact|
            updated_row = old_rows.find {|row| row['id'].to_i == contact.id}
            updated_row = self.new.clean_csv_row(updated_row)
            if updated_row
              contact.attributes = updated_row
              contact.save_with_validation(false) unless test_run
              port[:rows_updated] += 1
            else
              if reconcile
                contact.destroy unless test_run
                port[:rows_deleted] += 1
              end
            end
          end
          new_rows.each do |row|
            #create new rows
            #new rows should update the row user from the db
            unless template_class
              new_contact = self.new(row)
            else
              new_contact = template_class.translate_in(self,row)
            end
            if self.unique_field && self.unique_field.is_a?(Symbol) && loaded_contact = self.find(:first, :conditions => {self.unique_field => new_contact.send(self.unique_field)})
              template_class.translate_in(loaded_contact, row)
              port[:rows_updated] += 1
              loaded_contact.valid?
              loaded_contact.save_with_validation(false) unless test_run
            else
              new_contact.valid?
              new_contact.save_with_validation(false) unless test_run
              port[:rows_added] += 1
            end
          end
          port
        end

        protected
      end

      module InstanceMethods

        def value_for_column(column_name)
          if template
            value = template.translate_out(self, column_name)
          else
            value = self[column_name]
          end
          if value.is_a?(Time)
            value.strftime('%m/%d/%Y %H:%M:%S') 
          else
            value
          end
        end

        def include_associations
          self.class.include_associations || []
        end

        private
        def method_missing(method_name, *args)
          meth = method_name.to_s
          if meth =~ /\_name\=$/ && included_association_method?(meth)
            set_by_name(meth.gsub('_name=',''),args[0])
          elsif meth =~ /\_name$/ && included_association_method?(meth)
            get_by_name(meth.gsub('_name',''))
          else
            super
          end
        end

        def included_association_method?(meth_name)
          include_associations.include?(meth_name.gsub(/_name(\=)?/,'').to_sym)
        end

        def set_by_name(attribute, name)
          return unless self.class.reflections.keys.include?(attribute.to_sym)
          related = self.class.reflections[attribute.to_sym].class_name.constantize.find_first_by_name(name)
          write_attribute((attribute + '_id').to_sym,related.id) if related && related.id
        end

        def get_by_name(attribute)
          self.send(attribute.to_sym).to_s
        end



        def template
          self.class.template_class
        end
      end
    end
  end
end