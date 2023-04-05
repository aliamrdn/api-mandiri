class Aksesmodul
  include Mongoid::Document
  include Mongoid::Timestamps
  field :moduls_id, type: String
  field :nama_modul, type: String
  field :header_modul, type: String
  field :url, type: String
  field :user_roles_id, type: String
  field :page, type: String
  field :cari, type: String

  # belongs_to :moduls, optional: true
  # belongs_to :user_roles, optional: true
end
