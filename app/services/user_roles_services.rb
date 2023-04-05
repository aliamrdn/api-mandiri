class UserRolesServices

	@@model = UserRole

	def find(obj)

		condition = /#{obj[:nama_modul]}/i
		@list = @@model.where(:nama_modul => condition)
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

	def get_all(obj)

		@list = @@model.all
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
        nama_modul = (obj[:nama_modul])
		@list = @@model.where(nama_modul: obj[:nama_modul], header_modul: header_modul)
		if @list.present?
			
			response = {
				status: true,
				message: "Success",
				content:  {data: @list}
			}
		else
			response = {
				status: false,
				message: " #{obj[:nama_modul]} Data Not Found!",
				content:  nil
			}
		end
		return response
	end


	def add(obj_data)


		@list = @@model.count
		if @list == 0

			id_role = 1
			
		else
			id_role = @list + 1
		end

		obj = {
			name_role: obj_data['name_role'],
			id_role: id_role,
            status: obj_data['status']
		}

		content = @@model.new(obj)
		#response = ResponseApi.new

		if content.save
			response = {
				status: true,
				message: "Data Berhasil Disimpan!",
				content:  obj
			}
		else
			response = {
				status: false,
				message: "Gagal Simpan Data!",
				content:  nil
			}
		end

		return response
	end


	# ----------------------------
	# UPDATE DATA
	# ----------------------------
	def update(obj_data)

		role = @@model.find_by(id: obj_data[:id])
		obj = {
			name_role: obj_data[:name_role],
			id_role: obj_data[:id_role],
            status: obj_data[:status]
		}

		if role.present?
			# response = ResponseApi.new
			content = role.update(obj)
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