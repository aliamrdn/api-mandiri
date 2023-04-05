class SystemSetting
  include Mongoid::Document
  field :sys_key, type: String
  field :sys_val, type: String
end
