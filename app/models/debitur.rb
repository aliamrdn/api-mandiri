class Debitur
  include Mongoid::Document
  include Mongoid::Timestamps
  field :namanasabah, type: String
  field :notakredit, type: Integer
  field :tujuanpenggunaan, type: String
  field :nama_rm, type: String
  field :no_hprm, type: Integer
  field :department, type: String
  field :kolektibilitas, type: Integer
  field :limitobligor, type: Integer
end
