class V10::MandiriController < ApplicationController
	before_action :authenticate, except: [:check_batch]

	# -----------------------------------------------------
	# - API DASHBOARD MANDIRI
	# - Author: Team Project (EKI, ERVAN, HAFIDZ, ALI)
	# -----------------------------------------------------

	# -----------------------------------------------------
	# - GET REQUEST BATCH
	# -----------------------------------------------------
	def get_request_batch
		keyword = params[:keyword].present? ? params[:keyword] : ''
		page = (params[:page].present? ? params[:page] : 1)

		if keyword == ''
			@batch = Batch.all.page(page).per(10)
		else
			@batch = Batch.where(:nominal => keyword).page(page).per(10)
		end  
		Rails.logger.info "########## BATCH #{@batch.to_json}"

		@meta = {
			current_page: @batch.current_page.to_i,
			next_page: @batch.next_page.to_i,
			prev_page: @batch.prev_page.to_i,
			total_pages: @batch.total_pages.to_i,
		}
		
		if @batch.present?
		@ret = {
			status: true, 
			message: "Ok", 
			data: @batch,
			meta: @meta
		}
		else
		@ret = {
			status: false,
			message: "Data Not Found", 
			data: nil, 
			meta: nil
		}
		end

		render json: @ret

	rescue Exception => ex
		@ret = {status: false, message: "Failed to get data! #{ex}", data: nil, meta: nil}
	end

	# -----------------------------------------------------
	# - REQUEST NEW BATCH
	# -----------------------------------------------------
	def request_batch
		begin
			nparam = [{"amount": param_req_batch[:amount].to_i}]

			res = HTTParty.post(
			  "#{ENV['IP_API_ITD']}mandiri_request_data.php", 
			  	:body => nparam.to_json,
	      		:headers => { 'Content-Type' => 'application/json' }
			)

			res_new = JSON.parse(res)
			nopk = param_req_batch[:nopk]
			created_by = param_req_batch[:created_by]
			
			# SUCCESS
			# -----------------------------------------------------
			if res_new['status'].present? && res_new['status'] == '200'

				# INSERT BATCH DATA
				# -----------------------------------------------------
				names = "#{SecureRandom.hex}"
				data = {name: "BATCH-#{names rescue 'N/A'}", token: (res_new['token'] rescue 'N/A'), status: '0', status_app: '0', description: '', user_approver: '', approve_date: '', nopk: nopk, created_by: created_by, nominal: param_req_batch[:amount].to_i}
				batch = Batch.new(data)
				batch.save

				log = LogApprovalPencairan.new({token: (res_new['token'] rescue 'N/A'), status: '0', status_app: '0', user_approver: '', approve_date: '', created_by: created_by, data: data})
				log.save

				ret = {
					status: true,
					message: res_new['msg'],
					amount: res_new['amount'],
					token: res_new['token']
				}

			# FAILED
			# -----------------------------------------------------
			else

				ret = {
					status: false,
					message: (res_new['msg'] rescue 'Failed to request batch! try again later..'),
					amount: param_req_batch[:amount].to_i
				}

			end

			render json: ret
			# return

		# CATH ERROR
		# -----------------------------------------------------
		rescue Exception => ex
			ret = {
				status: false,
				message: "Failed to request batch! Error: #{ex}",
				amount: param_req_batch[:amount].to_i
			}
			render json: ret
		end
	end

	# -----------------------------------------------------
	# - REQUEST OS PK
	# -----------------------------------------------------
	def request_ospk
		begin
			nopk = param_req_ospk[:nopk]
			batch = Batch.where(nopk: nopk) # find nopk all row
			str = ''
			

			if batch.present?
				# looping token untuk ke api ITD 
				# -----------------------------------------------------
				batch.each do |item|
					if (str.length > 0)
						str = str + '|' + item['token'].to_s
					end
					if (str.length == 0)
						str = str + item['token'].to_s
					end
				end

				nparam = [{"batch": str}]
				res = HTTParty.post(
					"#{ENV['IP_API_ITD']}mandiri_bulk_summary.php", 
						:body => nparam.to_json,
						:headers => { 'Content-Type' => 'application/json' }
				)
				res_new = JSON.parse(res)

				ret = {
					status: true,
					message: res_new['msg'],
					totalos: res_new['totalos'],
					totalplafond: res_new['totalplafond'],
					nopk: nopk
				}

			# FAILED
			# -----------------------------------------------------
			else

				ret = {
					status: false,
					message: 'Failed to get OS PK! try again later..'
				}

			end

			render json: ret
			# return

		# CATH ERROR
		# -----------------------------------------------------
		rescue Exception => ex
			ret = {
				status: false,
				message: "Failed to get OS PK! Error: #{ex}"
			}
			render json: ret
		end
	end

	# -----------------------------------------------------
	# - REQUEST UPDATE BATCH
	# -----------------------------------------------------
	def update_batch
		begin
			nopk = param_update_batch[:nopk]
			name = param_update_batch[:name]
			batch = Batch.find_by(name: name)

			if batch.present?
				# UPDATE BATCH DATA
				# -----------------------------------------------------
				batch.nopk = nopk
				batch.updated_at = DateTime.now
				update = batch.update

				ret = {
					status: true,
					message: 'Success to update batch!'
				}

			# FAILED
			# -----------------------------------------------------
			else

				ret = {
					status: false,
					message: 'Failed to update batch! try again later..'
				}

			end

			render json: ret
			# return

		# CATH ERROR
		# -----------------------------------------------------
		rescue Exception => ex
			ret = {
				status: false,
				message: "Failed to update batch! Error: #{ex}"
			}
			render json: ret
		end
	end
	
	# -----------------------------------------------------
	# - VIEW BATCH Detail
	# -----------------------------------------------------
	def view_batch_detail
		begin
			# FIND BATCH
			# -----------------------------------------------------
			batch = Batch.find_by(name: param_view_batch[:name])
			res = HTTParty.get(
				"#{ENV['IP_API_ITD']}mandiri_view_batch.php",
				:headers => { 'Content-Type' => 'application/json' }
				)
				nilaireq = 0
				status = 0
				created_at = ''
				undername = ''
				no = 0
				if res.present?
					res_new = JSON.parse(res)
					res_new.each do |item|
					no = no + 1
						if item['token'] == batch.token
							nilaireq = item['amount']
							status = item['status']
							created_at = item['created_at']
							undername = 'BATCH ' + no.to_s
						end
					end
				end

			
			total_plafond = 0
			total_installment = 0
			total_base_outstanding = 0
			total_pay_outstanding = 0
			lancar = 0
			tidak_lancar = 0
			total_data = 0
			if batch.present?
				res = HTTParty.get(
					"#{ENV['IP_API_ITD']}mandiri_view_data.php?token=#{batch.token}",
		      		:headers => { 'Content-Type' => 'application/json' }
				)

				if res.present?
					res_new = JSON.parse(res)
					arrku = []
					res_new.each do |item|
						total_plafond = total_plafond + item['plafond'].to_i
						total_installment = total_installment + item['angsuran'].to_i
						total_base_outstanding = total_base_outstanding + item['outstanding'].to_i
						total_pay_outstanding = total_pay_outstanding + item['terbayar'].to_i
						if item['kolektibilitas'] == 1
							lancar = lancar + 1
						else 
							tidak_lancar = tidak_lancar + 1
						end
						total_data = total_data + 1
					end

					kolektibilitas ={
						lancar: lancar,
						tidak_lancar: tidak_lancar
					}
					dataku = {
						total_plafond: total_plafond,
						total_installment: total_installment,
						total_base_outstanding: total_base_outstanding,
						total_pay_outstanding: total_pay_outstanding,
						kolektibilitas: kolektibilitas,
						underlying_name: undername,
						nominal_pencairan: nilaireq,
						status: status,
						total_data: total_data,
						created_at: created_at
					}
					
					data ={
						data: dataku
					}

					ret = {
						status: true,
						message: "SUCCESS",
						result: (data rescue [])
						# data: (res_new rescue [])
					}
				else
					ret = {
						status: false,
						message: "Failed to get batch! Batch doesn't exist..",
						result: []
					}
				end

			else

				ret = {
					status: false,
					message: "Failed to get batch! Batch doesn't exist..",
					result: nil
				}
			end
			
			render json: ret

		rescue Exception => ex

			ret = {
				status: false,
				message: "Failed to get batch! Error: #{ex}",
				result: nil
			}
			render json: ret

		end
	end

	# -----------------------------------------------------
	# - VIEW BATCH
	# -----------------------------------------------------
	def view_batch
		begin
			# FIND BATCH
			# -----------------------------------------------------
			page = param_view_batch[:pages]
			row = param_view_batch[:row]
			batch = Batch.find_by(name: param_view_batch[:name])
			total_data = 0
			if batch.present?
				res2 = HTTParty.get(
					"#{ENV['IP_API_ITD']}mandiri_view_batch.php",
		      		:headers => { 'Content-Type' => 'application/json' }
				)

				if res2.present?
					res_new2 = JSON.parse(res2)
					res_new2.each do |item|
						if item['token'] == batch.token
							total_data = item['total_data'].to_i
						end
					end
				end
				
				res = HTTParty.get(
					"#{ENV['IP_API_ITD']}mandiri_view_data.php?token=#{batch.token}&page=#{page}&row=#{row}",
		      		:headers => { 'Content-Type' => 'application/json' }
				)
				
				if res.present?
					res_new = JSON.parse(res)
					arrku = []
					res_new.each do |item|
						dataku = {
							id: item['nomorurut'],
							underlying_id:  batch.token,
							nasabah_id: item['clientid'],
							plafond: item['plafond'],
							installment: item['angsuran'],
							tenor: item['jangkawaktu'],
							settlement_date: item['tanggaltarik'],
							due_date: item['tanggalpencairan'],
							finish_date: item['tanggalpelunasan'],
							base_outstanding:  item['outstanding'],
							pay_outstanding: item['terbayar'],
							freq_pay: item['freqbayar'],
							arrears: 0,
							status_rec: 1,
							kolektibilitas: item['kolektibilitas'],
							created_at: "",
							updated_at: "",
							nasabah_region_id: item['cabang'],
							nasabah_group: item['kelompok'],
							nasabah_name: item['nama'],
							nasabah_created_at: '',
							nasabah_updated_at: '',
							nasabah_created_by: '',
							nasabah_updated_by: '',
							nasabah_status: item['status'],
							nasabah_is_delete: 0,
							underlying_name: batch.token, 
						}
						arrku.push(dataku)
					end
					last_page = (total_data/row.to_f).ceil
					
					page = {
						current_page: page,
						per_page: row,
						total: total_data,
						last_page: last_page,
					}

					result = {
						pagination: page,
						data: arrku
					}

					ret = {
						status: true,
						message: "SUCCESS",
						result: (result rescue [])
					}
				else
					ret = {
						status: false,
						message: "Failed to get batch! Batch doesn't exist..",
						result: []
					}
				end

			else

				ret = {
					status: false,
					message: "Failed to get batch! Batch doesn't exist..",
					result: nil
				}

			end
			
			render json: ret

		rescue Exception => ex

			ret = {
				status: false,
				message: "Failed to get batch! Error: #{ex}",
				data: nil
			}
			render json: ret

		end
	end

	# -----------------------------------------------------
	# - PROJECTION BATCH
	# -----------------------------------------------------
	def projection_batch
		begin

			# FIND BATCH
			# -----------------------------------------------------
			batch = Batch.find_by(name: param_view_batch[:name])
			if batch.present?
				
				res = HTTParty.get(
				  "#{ENV['IP_API_ITD']}mandiri_view_osprojection.php?token=#{batch.token}",
		      		:headers => { 'Content-Type' => 'application/json' }
				)

				if res.present?
					res_new = JSON.parse(res)
					ret = {
						status: true,
						message: "SUCCESS",
						data: (res_new rescue [])
					}
				else
					ret = {
						status: false,
						message: "Failed to get batch projection! Batch projection doesn't exist..",
						data: []
					}
				end

			else

				ret = {
					status: false,
					message: "Failed to get batch! Batch doesn't exist..",
					data: nil
				}

			end
			
			render json: ret

		rescue Exception => ex

			ret = {
				status: false,
				message: "Failed to get batch! Error: #{ex}",
				data: nil
			}
			render json: ret
			
		end
	end

	# -----------------------------------------------------
	# - Scheduler Check Data Batch Pending
	# -----------------------------------------------------
	def check_batch
		begin
			batch = Batch.where(status: 'PENDING')
			if batch.present?
				batch.each do |item|
					Rails.logger.info "=====>>>> data : #{item.to_json}"
					res = HTTParty.get(
						"#{ENV['IP_API_ITD']}mandiri_view_data.php?token=#{item.token}",
						:headers => { 'Content-Type' => 'application/json' }
					)
					if res.present?
						batch = Batch.find_by(name: item.name)
						batch.status = 'Terima Data'
						update = batch.update
						if update
							ret = {
								status: true,
								message: "SUCCESS",
								data: item
							}
						else
							ret = {
								status: false,
								message: "Failed to update batch status!",
								data: item
							}
						end
					else
						ret = {
							status: false,
							message: "Data tidak ditemukan!",
							data: item
						}
					end
					LogCheckBatch.new({data: ret})
				end
			else
				ret = {
					status: false,
					message: "Tidak ada data pending",
					data: nil
				}
				LogCheckBatch.new({data: ret})
			end

		rescue Exception => ex
			ret = {
				status: false,
				message: "Failed to get data! Error: #{ex}",
				data: nil
			}
			LogCheckBatch.new({data: ret})
		end
	end

	# -----------------------------------------------------
	# - LIST APPROVAL BATCH
	# -----------------------------------------------------
	def list_approval_batch
		begin

			# FIND BATCH
			# -----------------------------------------------------
			# Status App = 0 : App RM, 1 : App DH, 2 : App CO, 3 : REJECTED
			# Status = 0 : Pending, 1 : Terima Data, 2 : Approved, 3 : REJECTED

			keyword = params[:keyword].present? ? params[:keyword] : ''
			page = (params[:page].present? ? params[:page] : 1)

			if keyword == ''
				if params[:role_id] == '1'
					batch = Batch.where(status_app: 0, status: 1).page(page).per(10)
				elsif params[:role_id] == '2'
					batch = Batch.where(status_app: 1, status: 1).page(page).per(10)
				elsif params[:role_id] == '3'
					batch = Batch.where(status_app: 2, status: 1).page(page).per(10)
				else 
					batch = Batch.all.page(page).per(10)
				end
			else
				if params[:role_id] == '1'
					batch = Batch.where(status_app: 0, status: 1, :nominal => keyword).page(page).per(10)
				elsif params[:role_id] == '2'
					batch = Batch.where(status_app: 1, status: 1, :nominal => keyword).page(page).per(10)
				elsif params[:role_id] == '3'
					batch = Batch.where(status_app: 2, status: 1, :nominal => keyword).page(page).per(10)
				else 
					batch = Batch.all.page(page).per(10)
				end
			end

			Rails.logger.info "########## BATCH #{batch.to_json}"

			@meta = {
				current_page: batch.current_page.to_i,
				next_page: batch.next_page.to_i,
				prev_page: batch.prev_page.to_i,
				total_pages: batch.total_pages.to_i,
			}
			
			if batch.present?
				ret = {
					status: true, 
					message: "Ok", 
					data: batch,
					meta: @meta
				}
			else
				ret = {
					status: false,
					message: "Data Not Found", 
					data: nil, 
					meta: nil
				}
			end
			
			render json: ret

		rescue Exception => ex

			ret = {
				status: false,
				message: "Failed to get batch! Error: #{ex}",
				data: nil,
				meta: nil
			}
			render json: ret
			
		end
	end

	# -----------------------------------------------------
	# - APPROVAL BATCH
	# -----------------------------------------------------
	def approval_batch
		begin

			# FIND BATCH
			# -----------------------------------------------------
			# Status App = 0 : App RM, 1 : App DH, 2 : App CO, 3 : REJECTED
			# Status = 0 : Pending, 1 : Terima Data, 2 : Approved, 3 : REJECTED

			batch = Batch.find_by(name: param_approve_batch[:name])

			status_tif = ''
			status_app = ''

			status = param_approve_batch[:status]

			if status == '0'
				status_app = '1'
				batch.status_app = status_app
			end
			if status == '1'
				status_app = '2'
				batch.status_app = status_app
			end
			if status == '2'
				status_tif = '2'
				batch.status = status_tif
			end
			if status == '3'
				status_tif = '3'
				status_app = '3'
				batch.status = status_tif
				batch.status_app = status_app
			end

			if batch.present?

				if status_tif.present?
					nparam = [{"token": batch.token,"status": status_tif.to_i}]
					res = HTTParty.post(
						"#{ENV['IP_API_ITD']}mandiri_push_approval.php",
						:body => nparam.to_json,
						:headers => { 'Content-Type' => 'application/json' }
					)
				end

				batch.description = param_approve_batch[:deskripsi]
				batch.user_approver = param_approve_batch[:user_approver]
				batch.approve_date = DateTime.now
				update = batch.update
				
				if update
					log = LogApprovalPencairan.new({token: batch.token, status: status_tif, status_app: status_app, user_approver: param_approve_batch[:user_approver], approve_date: DateTime.now, created_by: param_approve_batch[:user_approver], data: param_approve_batch.to_json})
					log.save

					ret = {
						status: true,
						message: "SUCCESS",
						data: nparam
					}
				else
					ret = {
						status: false,
						message: "Failed to update batch status!",
						data: nil
					}
				end

			else

				ret = {
					status: false,
					message: "Failed to get batch! Batch doesn't exist or already approved / rejected..",
					data: nil
				}

			end
			
			render json: ret

		rescue Exception => ex

			ret = {
				status: false,
				message: "Failed to get batch! Error: #{ex}",
				data: nil
			}
			render json: ret
			
		end
	end

	# -----------------------------------------------------
	# - VIEW BATCH LIST
	# -----------------------------------------------------
	def view_batch_list
		begin

			# -----------------------------------------------------
				res = HTTParty.get(
				  "#{ENV['IP_API_ITD']}mandiri_view_batch.php",
		      		:headers => { 'Content-Type' => 'application/json' }
				)

				if res.present?
					res_new = JSON.parse(res)
					x = []
					no = 0
					total_plafond = 0
					total_os = 0
					total_nominalpencairan = 0
					created_by = ''
					res_new.each do |item|
						batch = Batch.find_by(token: item['token'])
						sts = item['status'] 
						no = no + 1
						#if batch.created_by.present?
						#	created_by = ''
						#else 
						#	created_by = batch.created_by.to_s
						#end
						
						#if batch.status == 'PENDING'
						#	sts = 0
						#end
						#if batch.status == 'APPROVED RM'
						#	sts = 2
						#end
						#if batch.status == 'APPROVED DH'
						#	sts = 3
						#end
						#if batch.status == 'APPROVED CO'
						#	sts = 4
						#end
						#if batch.status == 'REJECTED'
						#	sts = 5
						#end
						
						total_plafond = total_plafond + item['total_plafond'].to_i
						total_os = total_os + item['total_outstanding'].to_i
						total_nominalpencairan = total_nominalpencairan + item['amount'].to_i
						z = {
							underlying_id: item['token'],
							id_pengajuan: no,
							comp_id: 'CID001',
							created_at: item['created_at'],
							total_data: item['total_data'],
							total_plafond: item['total_plafond'],
							total_outstanding: item['total_outstanding'],
							status: sts,
							file_status: 0,
							file_name: '-',
							id_generate: '',
							underlying_name: 'BATCH ' + no.to_s,
							nominal_pencairan: item['amount'],
							nopk: batch.nopk
						}
						x.push(z)
					end
					y = {
							total_plafond: total_plafond,
							total_outstanding: total_os,
							total_nominal_pencairan: total_nominalpencairan,
						}
					xx = {
						resume: y,
						total: no,
						data: x
					}
					ret = {
						status: true,
						message: "SUCCESS",
						result: (xx rescue [])
					}
				else
					ret = {
						status: false,
						message: "Failed to get view batch! view batch doesn't exist..",
						result: []
					}
				end
			
			render json: ret

		rescue Exception => ex

			ret = {
				status: false,
				message: "Failed to get view batch! Error: #{ex}",
				result: nil
			}
			render json: ret
			
		end
	end

	# -----------------------------------------------------
	# - create NPL
	# -----------------------------------------------------
	def create_npl
		begin
			nilai = params[:nilai].to_f
			tglberlaku = params[:tglberlaku]
			date = DateTime.parse(tglberlaku)

			if tglberlaku.present? && nilai.present?
				
				# INSERT NPL DATA
				# -----------------------------------------------------
				names = "#{SecureRandom.hex}"
				npl = Npl.new({nilai: nilai, tglberlaku: date, name: "npl-#{names}"})
				npl.save

				ret = {
					status: true,
					nilai: nilai,
					tglberlaku: tglberlaku,
					name: "npl-#{names}"
				}

				#FAILED
				# -----------------------------------------------------
			else

				ret = {
					status: false,
					message: ('Failed to create NPL! try again later..'),
					amount: param_create_npl[:nilai].to_f
				}

			end

		# CATH ERROR
		# -----------------------------------------------------
		rescue Exception => ex
			ret = {
				status: false,
				message: "Failed to create NPL! Error: #{ex}",
				amount: param_create_npl[:nilai].to_f
			}
		end
		render json: ret
	end

	# -----------------------------------------------------
	# - view NPL
	# -----------------------------------------------------
	def view_npl
		begin
			npl = Npl.all.sort({"tglberlaku": -1})
			x=[]
			no = 0
			if npl.present?
				npl.each do |item|
					z = {
						name: item['name'],
						tglberlaku: item['tglberlaku'],
						nilai: item['nilai']
					}
					x.push(z)
				end
			end
			
			render json: x
		end
	end

	# -----------------------------------------------------
	# - view detail NPL
	# -----------------------------------------------------
	def view_detail_npl
		begin
			name = params[:name]
			npl = Npl.find_by(name: name)

			if npl.present?
				ret = {
					status: true,
					message: 'Success to View Detail npl!' + param_create_npl.to_s,
					data: npl
				}
			else

				ret = {
					status: false,
					message: 'Failed to View Detail npl! try again later..' + param_create_npl.to_s,
					data: ''
				}

			end

			render json: ret
			# return

		# CATH ERROR
		# -----------------------------------------------------
		rescue Exception => ex
			ret = {
				status: false,
				message: "Failed to View Detail npl! Error: #{ex}",
				data: ''
			}
			render json: ret
		end
	end

	# -----------------------------------------------------
	# - update NPL
	# -----------------------------------------------------
	def update_npl
		begin
			name = params[:name]
			nilai = params[:nilai].to_f
			tglberlaku = params[:tglberlaku]
			date = DateTime.parse(tglberlaku)

			npl = Npl.find_by(name: name)

			if npl.present?
				# UPDATE NPL DATA
				# -----------------------------------------------------
				npl.nilai = nilai
				npl.tglberlaku = date
				update = npl.update

				ret = {
					status: true,
					message: 'Success to update npl!'
				}

			# FAILED
			# -----------------------------------------------------
			else

				ret = {
					status: false,
					message: 'Failed to update npl! try again later..'
				}

			end

			render json: ret
			# return

		# CATH ERROR
		# -----------------------------------------------------
		rescue Exception => ex
			ret = {
				status: false,
				message: "Failed to update npl! Error: #{ex}"
			}
			render json: ret
		end
	end

	# -----------------------------------------------------
	# - VIEW Total Batch
	# -----------------------------------------------------
	def view_batch_total
		begin
			# FIND BATCH
			# -----------------------------------------------------
			batch = Batch.all
			installment=[]
			projection=[]
			if batch.present?
				sdate1 = ''
				edate1 = ''
				os1 = 0
				sdate2 = ''
				edate2 = ''
				os2 = 0
				sdate3 = ''
				edate3 = ''
				os3 = 0
				sdate0 = ''
				edate0 = ''
				os0 = 0
				batch.each do |batchitem|
					res = HTTParty.get(
						"#{ENV['IP_API_ITD']}mandiri_view_osprojection.php?token=#{batchitem.token}",
							:headers => { 'Content-Type' => 'application/json' }
					  )
					
					if res.present?
						res_new = JSON.parse(res)
						# render json: res_new
						# return
						
						if ((sdate0 == '') && (edate0 == ''))
							sdate0 = res_new['installment'][0]['sdate']
							edate0 = res_new['installment'][0]['edate']
							os0 = os0 + res_new['installment'][0]['os'].to_i
						elsif ((sdate0 == res_new['installment'][0]['sdate']) && (edate0 == res_new['installment'][0]['edate']))
							os0 = os0 + res_new['installment'][0]['os'].to_i
						end 

						if ((sdate1 == '') && (edate1 == ''))
							sdate1 = res_new['projection'][0]['sdate']
							edate1 = res_new['projection'][0]['edate']
							os1 = os1 + res_new['projection'][0]['os'].to_i
						elsif ((sdate1 == res_new['projection'][0]['sdate']) && (edate1 == res_new['projection'][0]['edate']))
							os1 = os1 + res_new['projection'][0]['os'].to_i
						end 

						if ((sdate2 == '') && (edate2 == ''))
							sdate2 = res_new['projection'][1]['sdate']
							edate2 = res_new['projection'][1]['edate']
							os2 = os2 + res_new['projection'][1]['os'].to_i
						elsif ((sdate2 == res_new['projection'][1]['sdate']) && (edate2 == res_new['projection'][1]['edate']))
							os2 = os2 + res_new['projection'][1]['os'].to_i
						end 

						if ((sdate3 == '') && (edate3 == ''))
							sdate3 = res_new['projection'][2]['sdate']
							edate3 = res_new['projection'][2]['edate']
							os3 = os3 + res_new['projection'][2]['os'].to_i
						elsif ((sdate3 == res_new['projection'][2]['sdate']) && (edate3 == res_new['projection'][2]['edate']))
							os3 = os3 + res_new['projection'][2]['os'].to_i
						end 
					end
				end
				projection1 = {
					sdate: sdate1,
					edate: edate1,
					os: os1
				}
				projection.push(projection1)
				projection2 = {
					sdate: sdate2,
					edate: edate2,
					os: os2
				}
				projection.push(projection2)
				projection3 = {
					sdate: sdate3,
					edate: edate3,
					os: os3
				}
				projection.push(projection3)

				installment1 = {
					sdate: sdate0,
					edate: edate0,
					os: os0
				}
				installment.push(installment1)

				xx = {
					projection: projection,
					installment: installment
				}

				ret = {
					status: true,
					message: "SUCCESS",
					result: (xx rescue [])
				}
			else

				ret = {
					status: false,
					message: "Failed to get total batch! Total Batch doesn't exist..",
					result: nil
				}
			end
			
			render json: ret

		rescue Exception => ex

			ret = {
				status: false,
				message: "Failed to get total batch! Error: #{ex}",
				result: nil
			}
			render json: ret

		end
	end

	private
	# STRONG PARAMETERS
	# -----------------------------------------------------
	# - https://github.com/rails/strong_parameters
	# -----------------------------------------------------
	def param_req_batch
		params.permit(:amount, :nopk, :created_by)
	end

	def param_update_batch
		params.permit(:name, :nopk)
	end

	def param_view_batch
		params.permit(:name, :pages, :row)
	end

	def param_approve_batch
		params.permit(:name, :status, :user_approver, :deskripsi, :role_id)
	end

	def param_req_ospk
		params.permit(:nopk)
	end

	def param_create_npl
		params.permit(:nilai, :tglberlaku, :name)
	end
end
