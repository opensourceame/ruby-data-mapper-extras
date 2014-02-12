module DataMapper
  module Resource

    def all_error_messages

      error_messages = []

      parent_relationships.each do |relationship|

        parent = relationship.get(self)

        unless parent.valid?
          error_messages.concat(parent.errors.full_messages)
        end

      end

      self.errors.map { |err|

        if err.class == String
          error_messages.push(err)
        else
          if err.first.class == String
            error_messages.push(err.first)
          else
            error_messages.concat(err.first).full_messages
          end
        end
      }

      error_messages

    end
  end
end
