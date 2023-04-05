class Batch
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :token, type: String
  field :status, type: String
  field :description, type: String
  field :user_approver, type: String
  field :approve_date, type: DateTime
  field :created_by, type: String
  field :nopk, type: String
  field :nominal, type: Integer
  field :status_app, type: String
end
