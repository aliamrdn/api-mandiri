class Npl
  include Mongoid::Document
  include Mongoid::Timestamps
  field :nilai, type: String
  field :tglberlaku, type: DateTime
  field :name, type: String
end
