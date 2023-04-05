class App
  include Mongoid::Document
  field :name, type: String
  field :secret, type: String
  field :status, type: Integer
end
