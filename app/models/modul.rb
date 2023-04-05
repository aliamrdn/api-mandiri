class Modul
  include Mongoid::Document
  include Mongoid::Timestamps
  field :nama_modul, type: String
  field :header_modul, type: String
  field :status, type: Integer
  field :url, type: String
end
