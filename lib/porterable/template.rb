module Porterable
  class Template

    def column_names
      self.class.column_names
    end

    class << self
      attr_reader :map

      def set_map(*map_fields)
        @map = map_fields
        set_columns_from_map
      end

      def column_names
        @column_names ||= []
      end

      def columns
        @columns ||= {}
      end
      
      def translate_out(model_instance, column_name)
        column = columns[column_name]
        return nil unless column
        if column.is_a?(Array)
          column.collect {|c| translate_out(model_instance, c).to_s }.join(" ")
          return
        end
        case column
        when String
          model_instance.instance_eval(column)
        when Proc
          model_instance.instance_eval(&column)
        when Symbol
          model_instance.send(column)
        end
      rescue NoMethodError => e
        warn e
      end
      
      def translate_in(model_class_or_instance, row)
        model_instance = model_class_or_instance.is_a?(Class) ? model_class_or_instance.new : model_class_or_instance
        row.each do |column_name, value|
          column = columns[column_name]
          if column
            # Convert double-quotes into escaped double quotes (e.g. " => \")
            escaped_value = value ? value.gsub("\"", "\\\"") : ""
            # RAILS_DEFAULT_LOGGER.warn escaped_value
            translation = "self.#{column} = \"#{escaped_value}\""
            model_instance.instance_eval(translation)
          end
        end
        model_instance
      end

      protected
      def set_columns_from_map
        map.each do |column|
          case column
          when Array
            col = column.dup
            key = col.shift
            column_names << key
            columns[key] = (col.length > 1) ? col : col.first
          when Hash
            column.each do |key, col|
              column_names << key
              columns[key] = col
            end
          else
            column_names << column
            columns[column] = column
          end
        end
      end
    end
  end

end