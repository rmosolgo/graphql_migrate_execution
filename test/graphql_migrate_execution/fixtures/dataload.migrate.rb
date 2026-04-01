# frozen_string_literal: true
module Types
  module Something
    include Types::BaseInterface

    field :dataload_assoc, Types::Thing, dataload: { association: :one }

    def dataload_assoc
      dataload_association(:one)
    end

    field :dataload_object_1, Types::Thing, dataload: { with: MySource, by: [:two] }

    def dataload_object_1
      context.dataloader.with(MySource, :two).load(object)
    end

    field :dataload_object_2, Types::Thing, resolve_batch: true

    def self.dataload_object_2(objects, context)
      context.dataload_all(Sources::Nested::MySource, objects.map(&:id))
    end

    def dataload_object_2
      dataload(Sources::Nested::MySource, object.id)
    end

    field :dataload_rec, Types::Thing, dataload: { model: Something, using: :something_id }

    def dataload_rec
      dataload_record(Something, object.something_id)
    end

    field :dataload_rec_2, Types::Thing, dataload: { model: Something, using: :something_name, find_by: :name }

    def dataload_rec_2
      dataload_record(Something, object.something_name, find_by: :name)
    end

    field :dataload_complicated, Types::Thing

    def dataload_complicated
      a = 1 + 1
      dataload(Sources::SomeSource, :batch_key).load(a)
    end

    field :dataload_things, [Types::Thing], resolve_batch: true

    def self.dataload_things(objects, context)
      requests = objects.map { |object| context.dataloader.with(ThingsSource).request_all(object.thing_ids) }
      requests.map! { |reqs| reqs.map!(&:load) } # replace dataloader requests with loaded data
      requests
    end

    def dataload_things
      dataloader.with(ThingsSource).load_all(object.thing_ids)
    end

    field :dataload_more_things, [Types::Thing], resolver_method: :dataload_things_again, resolve_batch: :dataload_things_again

    def self.dataload_things_again(objects, context)
      requests = objects.map { |object| context.dataloader.with(Sources::Namespace::ThingsSource, :stuff).request_all(object[:thing_ids]) }
      requests.map! { |reqs| reqs.map!(&:load) } # replace dataloader requests with loaded data
      requests
    end

    def dataload_things_again
      dataload_all(Sources::Namespace::ThingsSource, :stuff, object[:thing_ids])
    end

    field :dataload_constant, Integer, resolve_batch: true

    def self.dataload_constant(objects, context)
      context.dataload_all(SomeSource, context, objects.map { |_obj| Thing.some.call })
    end

    def dataload_constant
      dataloader.with(SomeSource, context).load(Thing.some.call)
    end
  end
end
