class ModulServices

	# To Add Data (Eky)
	@@model = Modul

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

			id_modul = 1
			
		else
			id_modul = @list + 1
		end
		
		obj = {
			nama_modul: obj_data['nama_modul'],
            header_modul: obj_data['header_modul'],
			moduls_id: id_modul,
            status: obj_data['status'],
            url: obj_data['url']
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

		modul = @@model.find_by(id: obj_data[:id])
		obj = {
			nama_modul: obj_data[:nama_modul],
            header_modul: obj_data[:header_modul],
			moduls_id: obj_data[:moduls_id],
            status: obj_data[:status],
            url: obj_data[:url]
		}

		if modul.present?
			# response = ResponseApi.new
			content = modul.update(obj)
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