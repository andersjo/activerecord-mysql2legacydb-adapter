module Mysql2legacydb
  class DefaultTranslator
    def legacy_to_new(legacy_name)
      legacy_name.underscore
    end

    def new_to_legacy(new_name)
      new_name.to_s.camelize(:lower)
    end

  end
end
