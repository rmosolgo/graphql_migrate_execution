module SomeInterface
  include Types::BaseInterface

  field :name, String, null: false, resolve_each: :resolve_name

  resolver_methods do
    def resolve_name(object, context)
      object.graphql_object_name
    end
  end

  def name
    self.class.resolve_name(object, context)
  end

  field :title, String
end
