module SeedDumper

  # Dumper
  class Fetcher

    def self.fetch_data(klass, options={})
      # WHEN I convert from MySQL to Postgresql, having the timestamps matters!
      ignore = [] #['created_at', 'updated_at']
      ignore += options[:ignore].map(&:to_s) if options[:ignore].is_a? Array
      model_name = klass.name

      puts "Adding #{model_name.camelize} seeds."

      records = klass.all.map do |record|
        attr_s = [];

        record.attributes.delete_if { |k, v| ignore.include?(k) }.each do |key, value|
          value = value.class == Time ? "\"#{value}\"" : value.inspect
          value = nil if value.is_a?(String) && value == "\"\""
          value = nil if value == 'nil' || value == "nil"

          if :created_at == key or :updated_at == key
            attr_s.push("#{key.to_sym.inspect} => DateTime.parse('#{value}')")
          elsif not value.nil?
            attr_s.push("#{key.to_sym.inspect} => #{value}")# unless key == 'id'
          end


        end

        record_dump = "#{model_name.camelize}.create(#{attr_s.join(', ')})"
        record_dump = "#{record_dump}{|record| record.id = #{record.attributes['id']}}" if options[:dump_id] && record.attributes['id']
        record_dump
      end
      # / records.each_with_index

      records
    end

  end

end