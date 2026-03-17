# frozen_string_literal: true
module Types
  module Something
    include Types::BaseInterface

    field :dataload_assoc, Types::Thing

    def dataload_assoc
      dataload_association(:one)
    end

    field :dataload_object_1, Types::Thing

    def dataload_object_1
      context.dataloader.with(MySource, :two).load(object)
    end

    field :dataload_object_2, Types::Thing

    def dataload_object_2
      dataload(Sources::Nested::MySource, object.id)
    end

    field :dataload_rec, Types::Thing

    def dataload_rec
      dataload_record(Something, object.something_id)
    end

    field :dataload_rec_2, Types::Thing

    def dataload_rec_2
      dataload_record(Something, object.something_name, find_by: :name)
    end

    field :dataload_complicated, Types::Thing

    def dataload_complicated
      a = 1 + 1
      dataload(Sources::SomeSource, :batch_key).load(a)
    end

    field :dataload_things, [Types::Thing]

    def dataload_things
      dataloader.with(ThingsSource).load_all(object.thing_ids)
    end

    field :dataload_more_things, [Types::Thing], resolver_method: :dataload_things_again

    def dataload_things_again
      dataload_all(Sources::Namespace::ThingsSource, :stuff, object[:thing_ids])
    end
  end
end
