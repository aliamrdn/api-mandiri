class LogApprovalPencairan
  include Mongoid::Document
  include Mongoid::Timestamps
  field :token, type: String
  field :user_approver, type: String
  field :approve_date, type: String
  field :data, type: String
  field :status, type: String
  field :status_app, type: String
  field :created_by, type: String
  # field :pencairan_id, type: String
  # field :underlying_id, type: String
  # field :user_approve, type: String
  # field :approval_date, type: String
  # field :data, type: String
end
