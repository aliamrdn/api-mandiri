class LoginServices

	# To Add Data (Eky)
	@@model = User

	def find(obj)

		condition = /#{obj[:email]}/i
		@list = @@model.where(:email => condition)
		if @list.present?
			
			response = {
				status: true,
				message: "Success",
				content:  {data: @list}
			}
		else
			response = {
				status: false,
				message: "Data Not found",
				content:  nil
			}
		end
		return response
	end

	def check(obj) 
		password = Digest::MD5.hexdigest(obj[:password])
		@list = @@model.where(email: obj[:email], password: password)

		if @list.present?
			
			response = {
				status: true,
				message: "Login Success",
				content:  {data: @list}
			}
		else
			response = {
				status: false,
				message: "Wrong Password or Email ! #{obj[:email]} Not Registered",
				content:  nil
			}
		end
		return response
	end


	def add(obj_data)
		obj = {
			email: obj_data['email'],
			password: Digest::MD5.hexdigest(obj_data['password']),
			name: obj_data['name'],
			status: "1", # status 0 = tidak aktif 
			role_user: obj_data['role_user']

		}

		
		# cekemail = @@model.where("email=?", obj_data[:email])
		# Rails.logger.info "==============> LOGGER CEK USER : #{cekemail}"
		# if cekemail.present?

		# 	response = {
		# 		status: false,
		# 		message: "Sorry, This Email #{obj[:email]} Has Registered",
		# 		content:  nil
		# 	}

		# return response

		# end


		content = @@model.new(obj)
		#response = ResponseApi.new

		if content.save
			response = {
				status: true,
				message: "Success Regester Your Account!",
				content:  obj
			}
		else
			response = {
				status: false,
				message: "Failed to add data!",
				content:  nil
			}
		end

		return response
	end


	# ----------------------------
	# UPDATE DATA
	# ----------------------------
	def update(obj_data)
		
		user = @@model.find_by(id: obj_data[:id])
		obj = {
			email: obj_data[:email],
            password: Digest::MD5.hexdigest(obj_data[:password]),
			name: obj_data[:name],
            status: obj_data[:status],
            role_user: obj_data[:role_user]
		}

		if user.present?
			# response = ResponseApi.new
			content = user.update(obj)
			if content == true
				response = {
					status: true,
					message: "Update Data Success",
					content:  obj
				}
			else
				response = {
					status: false,
					message: "Failed to Update Data !",
					content:  obj
				}
			end
		else
			response = {
					status: false,
					message: "Failed to update data! Data not found.",
					content:  nil
				}
		end

		return response
	end

end