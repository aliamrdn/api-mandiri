class AksesmodulServices

	# To Add Data (Eky)
	@@model = Aksesmodul
	@@modul = Modul

	def find(obj)

		condition = /#{obj[:modul_id]}/i
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

	def get_by_role(obj)

		condition = /#{obj[:user_roles_id]}/i
		@list = @@model.where(:user_roles_id => condition)
		# @datanya =  @@model.where(:role_id => condition).pluck(:role_id)

		# @datanya = ::Modul.joins(:moduls).where(moduls: { role_id: condition })
		# Rails.logger.info "==============> LOGGER CEK USER : #{@datanya}"
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

		obj = {
			moduls_id: obj_data['moduls_id'],
            user_roles_id: obj_data['user_roles_id'],
			page: obj_data['page'],
            cari: obj_data['cari'],
            url: obj_data['url'],
			nama_modul: obj_data['nama_modul'],
            header_modul: obj_data['header_modul']

		}

		content = @@model.new(obj)
		Rails.logger.info "==============> URL : #{content}"
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

		aksesmodul = @@model.find_by(id: obj_data[:id])
		obj = {
			header_modul: obj_data[:header_modul],
            user_roles_id: obj_data[:user_roles_id],
			moduls_id: obj_data[:moduls_id],
			nama_modul: obj_data[:nama_modul],
			page: obj_data[:page],
			cari: obj_data[:cari],
            url: obj_data[:url]
		}

		if aksesmodul.present?
			# response = ResponseApi.new
			content = aksesmodul.update(obj)
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