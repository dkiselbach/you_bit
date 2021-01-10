module GraphQlMixins
  # Helper methods for habits within graphql
  module HelperMethods
    private

    def find_object_in_user_context(klass:, object_id: nil, object: nil)
      object = klass.find(object_id) if object_id

      unless user_has_access_to_object(object: object)
        raise Errors::ForbiddenError.new("User does not have access to the #{klass}",
                                         errors: I18n.t('graphql_devise.errors.bad_id'))
      end
      object
    end

    def user_has_access_to_object(object:)
      object.user_id == current_resource.id
    end
  end
end
