class LogCheckBatch
    include Mongoid::Document
    include Mongoid::Timestamps
    field :data, type: String
  end
  