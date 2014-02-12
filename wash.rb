module DataMapper
  module Resource

    # Return a new hash, containing only the key/value pairs
    # from +hash+ that are also present in this model's +properties+.
    #
    def wash(hash)

      return nil if hash.nil? || !hash.is_a?(Hash)

      keys = hash.keys.collect { |key| key.to_sym } & self.properties.collect { |prop| prop.name.to_sym }
      data = Hash[keys.collect { |k| [k,hash[k] || hash[k.to_s]] }]

      # iterate through related objects if there is matching data
      for relationship in relationships do

        relationship_data_name = relationship.instance_variable_name[1..-1]

        if hash.has_key?(relationship_data_name)

          if hash[relationship_data_name].is_a?(Array)    # handle multiple child related objects

            data[relationship_data_name] = hash[relationship_data_name]

            data[relationship_data_name].map! { |child| relationship.child_model.wash child }
          else
            # handle a one-to-one or parent
            if relationship.child_model == self
              data[relationship_data_name] = relationship.parent_model.wash(hash[relationship_data_name])
            else
              data[relationship_data_name] = relationship.child_model.wash(hash[relationship_data_name])
            end
          end
        end

      end

      if @@auto_wash_fields
        @@auto_wash_fields.each |field| do
          data.delete(field)
        end
      end

      data

    end
  end
end
