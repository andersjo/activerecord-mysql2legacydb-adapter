
module ActiveRecord
  class Base
    # same as "def.self.mysql2_connection(config)" in mysql2 gem
    # except that the ConnectionAdapter returned is a Mysql2LegacyAdapter
    # instead of a regular Mysql2Adapter
    def self.mysql2legacydb_connection(config)
      config[:username] = 'root' if config[:username].nil?

      if Mysql2::Client.const_defined? :FOUND_ROWS
        config[:flags] = Mysql2::Client::FOUND_ROWS
      end

      client = Mysql2::Client.new(config.symbolize_keys)
      options = [config[:host], config[:username], config[:password], config[:database], config[:port], config[:socket], 0]
      ConnectionAdapters::Mysql2LegacyDBAdapter.new(client, logger, options, config)
    end
  end

  module ConnectionAdapters
    class Mysql2LegacyDBAdapter < Mysql2Adapter
      def legacy_to_new(legacy_name)
        legacy_name.underscore
      end
      
      def new_to_legacy(new_name)
        new_name.to_s.camelize(:lower)
      end

      def columns(table_name, name = nil)
        sql = "SHOW FIELDS FROM #{quote_table_name(table_name)}"
        columns = []
        result = execute(sql, :skip_logging)
        result.each(:symbolize_keys => true, :as => :hash) { |field|
          columns << Mysql2Column.new(legacy_to_new(field[:Field]), field[:Default], field[:Type], field[:Null] == "YES")
        }
        columns
      end

      def tables_with_translation
        tables_without_translation.map {|table| legacy_to_new(table) }
      end
      alias_method_chain :tables, :translation

      def quote_column_name_with_translation(name)
        quote_column_name_without_translation(new_to_legacy(name))
      end
      alias_method_chain :quote_column_name, :translation

      def quote_table_name_with_translation(name)
        quote_table_name_without_translation(new_to_legacy(name))
      end
      alias_method_chain :quote_table_name, :translation

      def select_with_translation(sql, name = nil)
        select_without_translation(sql, name).collect { |row|
          translated = {}
          row.each { |key,val|
            translated[legacy_to_new(key)] = val
          }
          translated
        }
      end
      alias_method_chain :select, :translation
    end
  end
end
