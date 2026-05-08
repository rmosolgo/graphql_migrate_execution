module SomeInterface
  include Types::BaseInterface

  field :name, String, null: false

  def name
    object.graphql_object_name
  end

  field :title, String
end
