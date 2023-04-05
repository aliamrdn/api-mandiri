class RequestLog
  include Mongoid::Document
  include Mongoid::Timestamps
  field :module, type: String
  field :url, type: String
  field :status, type: String
end
