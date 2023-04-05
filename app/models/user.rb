class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :email, type: String
  field :name, type: String
  field :password, type: String
  field :status, type: Integer
  field :role_user, type: String
end
