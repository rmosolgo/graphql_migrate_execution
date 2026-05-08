module SomeInterface
  include Types::BaseInterface

  field :id, ID, null: false, resolve_each: true

  resolver_methods do
    def id(object, context)
      object.global_id
    end
  end

  def id
    self.class.id(object, context)
  end

  field :title, String
end
