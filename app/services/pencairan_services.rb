class PencairanServices

	@@model = Pencairan
	@@Pencairan_log = LogApprovalPencairan

	def find(obj)

		condition = /#{obj[:underlying_id]}/i
		@list = @@model.where(:underlying_id => condition)
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

	def add(obj_data)

		obj = {
			underlying_id: obj_data['underlying_id'],
			id_pengajuan: obj_data['id_pengajuan'],
			comp_id: obj_data['comp_id'],
			created_at: obj_data['created_at'],
			total_data: obj_data['total_data'],
			total_plafond: obj_data['total_plafond'],
			total_outstanding: obj_data['total_outstanding'],
			status: obj_data['status'],
			file_status: obj_data['file_status'],
			file_name: obj_data['file_name'],
			id_generate: obj_data['id_generate'],
			underlying_name: obj_data['underlying_name'],
			nominal_pencairan: obj_data['nominal_pencairan'],
			nopk: obj_data['nopk'],
			status_approve: obj_data['status_approve'],
			last_user_approve: obj_data['last_user_approve'],
			last_date_approve: Time.now.strftime("%Y-%d-%m %H:%M:%S ")
		}

		content = @@model.new(obj)
		if content.save
		Rails.logger.info "==============> URL : #{content}"
		@list = @@model.where(:underlying_id =>  obj_data['underlying_id'])
		obj_datalog = {
			pencairan_id: @list[0]['_id'],
			user_approve: @list[0]['last_user_approve'],
			underlying_id: @list[0]['underlying_id'],
			approval_date: @list[0]['last_date_approve'],
			data: "{comp_id => #{@list[0]['comp_id']}, underlying_name => #{@list[0]['underlying_name']}, nopk => #{@list[0]['nopk']}, status_approve => #{@list[0]['status_approve']} }"
		}

		content_log = @@Pencairan_log.new(obj_datalog)
		Rails.logger.info "==============> LOG : #{content_log}"
	else
		response = {
				status: false,
				message: "Gagal Simpan Data!",
				content:  nil
			}
	end

		if content.save && content_log.save
		
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

		pencairan = @@model.find_by(id: obj_data[:id])
		obj = {
			underlying_id: obj_data['underlying_id'],
			id_pengajuan: obj_data['id_pengajuan'],
			comp_id: obj_data['comp_id'],
			created_at: obj_data['created_at'],
			total_data: obj_data['total_data'],
			total_plafond: obj_data['total_plafond'],
			total_outstanding: obj_data['total_outstanding'],
			status: obj_data['status'],
			file_status: obj_data['file_status'],
			file_name: obj_data['file_name'],
			id_generate: obj_data['id_generate'],
			underlying_name: obj_data['underlying_name'],
			nominal_pencairan: obj_data['nominal_pencairan'],
			nopk: obj_data['nopk'],
			status_approve: obj_data['status_approve'],
			last_user_approve: obj_data['last_user_approve'],
			last_date_approve: obj_data['last_date_approve']
		}

		if pencairan.present?
			# response = ResponseApi.new
			content = pencairan.update(obj)
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

	# Get data Yang belum DI Approve Dept Head
	def get_data_approval_depthead(obj)

		get_data = @@model.where('status_approve' =>  '1')
		if get_data.present?
			response = {
					status: true,
					message: "Get Data Success",
					content:  get_data
				}
		else

			response = {
					status: false,
					message: "Data Not Found (Data Kosong)",
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


end