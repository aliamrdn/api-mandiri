class Pencairan
  include Mongoid::Document
  include Mongoid::Timestamps
  field :underlying_id, type: String
  field :id_pengajuan, type: Integer
  field :comp_id, type: String
  field :created_at, type: String
  field :total_data, type: Integer
  field :total_plafond, type: Integer
  field :total_outstanding, type: Integer
  field :status, type: Integer
  field :file_status, type: Integer
  field :file_name, type: String
  field :id_generate, type: Integer
  field :underlying_name, type: String
  field :nominal_pencairan, type: Integer
  field :nopk, type: String
  field :status_approve, type: Integer
  field :last_user_approve, type: String
  field :last_date_approve, type: String
end
