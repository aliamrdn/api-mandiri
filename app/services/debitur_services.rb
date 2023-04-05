class DebiturServices

	@@model = Debitur

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

		obj = {
			namanasabah: obj_data['namanasabah'],
            notakredit: obj_data['notakredit'],
			tujuanpenggunaan: obj_data['tujuanpenggunaan'],
            nama_rm: obj_data['nama_rm'],
            no_hprm: obj_data['no_hprm'],
			department: obj_data['department'],
			kolektibilitas: obj_data['kolektibilitas'],
            limitobligor: obj_data['limitobligor']
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

		debitur = @@model.find_by(id: obj_data[:id])
		obj = {
			namanasabah: obj_data['namanasabah'],
            notakredit: obj_data['notakredit'],
			tujuanpenggunaan: obj_data['tujuanpenggunaan'],
            nama_rm: obj_data['nama_rm'],
            no_hprm: obj_data['no_hprm'],
			department: obj_data['department'],
			kolektibilitas: obj_data['kolektibilitas'],
            limitobligor: obj_data['limitobligor']
		}

		if debitur.present?
			# response = ResponseApi.new
			content = debitur.update(obj)
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