namespace :seed_first do
	desc "Seed System Setting Data"
	task :system_settings => :environment do
		puts "=============> SEED SYSTEM SETTINGS"
		s = SystemSetting.new({
			sys_key: 'allow_request_token_after',
			sys_val: 3600
		})
		s.save
		s2 = SystemSetting.new({
			sys_key: 'session_token_expired',
			sys_val: 21600
		})
		s2.save
	end
end
