class AksesmodulsController < ApplicationController
  before_action :authenticate
  before_action :set_aksesmodul
  # before_action :set_aksesmodul, only: [:show, :update, :destroy]

  # GET /aksesmoduls
  def index
    # @aksesmoduls = Aksesmodul.all
    # render json: @aksesmoduls

    datax = []
    @page = params["page"].present? ? params["page"].to_i : 1
    @limit = params["limit"].present? ? params["limit"].to_i : 10
    @keyword = params['keyword']

    if params['keyword'].present?
      @akses_modul = Aksesmodul.where(:nama_modul => @keyword).page(@page).per(@limit)
    else 
      @akses_modul = Aksesmodul.all.page(@page).per(@limit)
    end

    if @akses_modul.present?
      @akses_modul.each do |item|
        array = {
          id: item.id.to_s,
          moduls_id: item.moduls_id,
          nama_modul: item.nama_modul,
          header_modul: item.header_modul,
          url: item.url,
          user_roles_id: item.user_roles_id,
          page: item.page,
          cari: item.cari
        }
        datax.push(array)
      end
    end
    
    meta ={
      next_page: @akses_modul.next_page,
      prev_page: @akses_modul.prev_page,
      current_page: @akses_modul.current_page,
      total_pages: @akses_modul.total_pages
    }
    
    result = {
      status: true,
      messages: 'Sukses',
      content: datax,
      meta: meta
    }
    Rails.logger.info "===>> result : #{result.to_json}"
    render json: result
  end

  # GET /aksesmoduls/1
  def show
    render json: @aksesmodul
  end

   # GET /aksesmoduls/2
  def get_modul_by_role

    @akses = Aksesmodul.where(user_roles_id: params[:user_roles_id])
    render json: {status: true, content: @akses}

  end

  # POST /aksesmoduls
  def create
    begin
      data = {
        moduls_id: params['moduls_id'],
        nama_modul: params['nama_modul'],
        header_modul: params['header_modul'],
        url: params['url'],
        user_roles_id: params['user_roles_id'],
        page: params['page'],
        cari: params['cari']
      }

      @akses_modul = Aksesmodul.new(data)

      if @akses_modul.save
        result = {
            status: true,
            message: 'Berhasil Tambah Akses Modul',
            content: @akses_modul
        }
      else
        result = {
            status: false,
            message: 'Gagal Tambah Akses Modul!'
        }
      end
      render json: result
    rescue Exception => ex
      result = {
        status: false,
        message: "Gagal Tambah Akses Modul! Error: #{ex}"
      }
      render json: result
    end
    # createakses = @aksesmodul.add(aksesmodul_params)
    # render json: createakses 
  end

  # PATCH/PUT /aksesmoduls/1
  def update
    begin
      akses_modul = Aksesmodul.find(params['id'])
      if akses_modul.present?

        akses_modul.moduls_id = params['moduls_id']
        akses_modul.nama_modul = params['nama_modul']
        akses_modul.header_modul = params['header_modul']
        akses_modul.url = params['url']
        akses_modul.user_roles_id = params['user_roles_id']
        akses_modul.page = params['page']
        akses_modul.cari = params['cari']
        update = akses_modul.save

        if update
          result = {
            status: true,
            message: 'Sukses Ubah Akses Modul'
          }
        else
          result = {
            status: false,
            message: 'Gagal Ubah Akses Modul!'
          }
        end
      else
        result = {
            status: false,
            message: 'Akses Modul Tidak ditemukan!'
          }
      end
      render json: result

    rescue Exception => ex
      result = {
        status: false,
        message: "Gagal Ubah Akses Modul! Error: #{ex}"
      }
      render json: result
    end
  end

  # DELETE /aksesmoduls/1
  def destroy
    @aksesmodul.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aksesmodul
      @aksesmodul = AksesmodulServices.new
    end

    # Only allow a trusted parameter "white list" through.
    def aksesmodul_params
      params.permit(:id, :url, :nama_modul, :header_modul, :moduls_id, :user_roles_id, :page, :cari)
    end
end
