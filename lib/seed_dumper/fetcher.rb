module SeedDumper

  # Dumper
  class Fetcher

    def self.fetch_data(klass, options={})
      # WHEN I convert from MySQL to Postgresql, having the timestamps matters!
      ignore = [] #['created_at', 'updated_at']
      ignore += options[:ignore].map(&:to_s) if options[:ignore].is_a? Array
      model_name = klass.name

      puts "Adding #{model_name.camelize} seeds."

      if klass and klass.respond_to?(:all)
        # Some objects, such as modules will not be scannable like this
        records = klass.all.map do |record|
          attr_s = [];

          record.attributes.delete_if { |k, v| ignore.include?(k) }.each do |key, value|
            vc = value.class

            value = value.class == Time ? "\"#{value}\"" : value.inspect
            value = nil if value.is_a?(String) && value == "\"\""
            value = nil if value == 'nil' || value == "nil"

            if not value.nil?
              #if vc == DateTime or (['created_at','updated_at','ordered_at','deleted_at'].include?(key)) or key.ends_with?('_at')
              if vc == DateTime or key.end_with?('_at')
                value_or_method = "DateTime.parse('#{value}')"
              elsif vc == Date
                value_or_method = "Date.parse('#{value}')"
              elsif vc == Time
                value_or_method = "Time.parse('#{value}')"
              elsif BigDecimal == vc
                value_or_method = value.to_f
              else
                value_or_method = value
              end

              attr_s.push("#{key.to_sym.inspect} => #{value_or_method}')")
            end


          end

          record_dump = "#{model_name.camelize}.create(#{attr_s.join(', ')})"
          record_dump = "#{record_dump}{|record| record.id = #{record.attributes['id']}}" if options[:dump_id] && record.attributes['id']
          record_dump
        end
        # / records.each_with_index
      end

      records
    end

  end

end