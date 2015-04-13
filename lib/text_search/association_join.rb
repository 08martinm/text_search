module TextSearch
  class AssociationJoin

    def initialize(model, association, attributes)
      @model = model
      @association = association
      @attributes = attributes
    end

    def to_sql
      klass = symbol_to_constant_class(@association, @model)
      options_as = @attributes.map { |attribute| "string_agg(#{klass.table_name}.#{attribute}, ' ') as #{attribute}" }.join ', '
      sql = @model.unscoped.joins(@association)
      .select("#{@model.table_name}.id as id, #{options_as}")
      .group("#{@model.table_name}.id").to_sql
      outer_join(sql, @association.to_s)
    end

    def outer_join(sql, assoc_alias)
      "LEFT OUTER JOIN (#{sql}) #{assoc_alias} on #{assoc_alias}.id = #{@model.table_name}.id"
    end

    # Changes a symbol into a class
    def symbol_to_constant_class(symbol, parent_class)
      name = symbol.to_s
      # If the classified version of the symbol is defined, then it has a model and can be made into a constant
      if Object.const_defined?(name.singularize.classify)
        name.singularize.classify.constantize
      else
        # If it isn't defined, this means that the attribute is a renamed version of a class
        parent_class.reflect_on_all_associations.each do |assoc|
          if assoc.name.to_s == name
            return assoc.class_name.classify.constantize
          end
        end
      end
    end
  end
end