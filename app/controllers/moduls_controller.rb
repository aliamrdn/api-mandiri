class ModulsController < ApplicationController
  before_action :authenticate, except: [:get_role_all]
  before_action :set_modul

  # GET /moduls
  def index
    datax = []
    @page = params["page"].present? ? params["page"].to_i : 1
    @limit = params["limit"].present? ? params["limit"].to_i : 10
    @keyword = params['keyword']

    if params['keyword'].present?
      @modul = Modul.where(:nama_modul => @keyword).page(@page).per(@limit)
    else 
      @modul = Modul.all.page(@page).per(@limit)
    end
    
    if @modul.present?
      @modul.each do |item|
        array = {
          id: item.id.to_s,
          nama_modul: item.nama_modul,
          header_modul: item.header_modul,
          status: item.status,
          url: item.url
        }
        datax.push(array)
      end
    end
    
    meta ={
      next_page: @modul.next_page,
      prev_page: @modul.prev_page,
      current_page: @modul.current_page,
      total_pages: @modul.total_pages
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

  # GET /moduls
  def get_all
    datax = []

    @moduls = Modul.all
    if @moduls.present?
      @moduls.each do |item|
        array = {
          id: item.id.to_s,
          nama_modul: item.nama_modul.to_s,
          header_modul: item.header_modul.to_s,
          url: item.url.to_s,
          status: item.status,
        }
        datax.push(array)
      end
      result = {
        status: true,
        messages: 'Sukses',
        content: datax
      }
      render json: result
    else
      result = {
        status: false,
        messages: 'Data tidak ditemukan'
      }
      render json: result
    end
  end

  # GET /moduls/1
  def show
    data = @modul.find(modul_params)
    render json: @modul
  end

  # POST /moduls
  def create
    begin
      data = {
        nama_modul: params['nama_modul'],
        header_modul: params['header_modul'],
        status: params['status'],
        url: params['url']
      }

      @modul = Modul.new(data)

      if @modul.save
        result = {
            status: true,
            message: 'Berhasil Tambah Modul',
            content: @modul
        }
      else
        result = {
            status: false,
            message: 'Gagal Tambah Modul!'
        }
      end
      render json: result
    rescue Exception => ex
      result = {
        status: false,
        message: "Gagal Tambah Modul! Error: #{ex}"
      }
      render json: result
    end
  end

  # PATCH/PUT /moduls/1
  def update

    begin
      modul = Modul.find(params['id'])
      if modul.present?

        modul.nama_modul = params['nama_modul']
        modul.header_modul = params['header_modul']
        modul.status = params['status']
        modul.url = params['url']
        update = modul.save

        if update
          result = {
            status: true,
            message: 'Sukses Ubah Modul'
          }
        else
          result = {
            status: false,
            message: 'Gagal Ubah Modul!'
          }
        end
      else
        result = {
            status: false,
            message: ' Modul Tidak ditemukan!'
          }
      end
      render json: result

    rescue Exception => ex
      result = {
        status: false,
        message: "Gagal Ubah Modul! Error: #{ex}"
      }
      render json: result
    end
  end

  # DELETE /moduls/1
  def destroy
    @modul.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_modul
      @modul = ModulServices.new
    end

    # Only allow a trusted parameter "white list" through.
    def modul_params
      params.permit(:id, :nama_modul, :header_modul, :status, :url)
    end
end
