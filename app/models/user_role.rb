class UserRole
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name_role, type: String
  field :status, type: Integer
end
