module SomeInterface
  include Types::BaseInterface

  field :id, ID, null: false

  def id
    object.global_id
  end

  field :title, String
end
