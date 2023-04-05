class Session
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :app
  field :token, type: String
  field :expired_time, type: String
  field :app_id, type: String
end
