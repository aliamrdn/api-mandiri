class UserRolesController < ApplicationController
  before_action :authenticate, except: [:get_role_all]

  # GET /user_roles
  def index
    datax = []
    @page = params["page"].present? ? params["page"].to_i : 1
    @limit = params["limit"].present? ? params["limit"].to_i : 10
    @keyword = params['keyword']

    if params['keyword'].present?
      @user_role = UserRole.where(:name_role => @keyword).page(@page).per(@limit)
    else 
      @user_role = UserRole.all.page(@page).per(@limit)
    end
    
    if @user_role.present?
      @user_role.each do |item|
        array = {
          id: item.id.to_s,
          name_role: item.name_role,
          status: item.status
        }
        datax.push(array)
      end
    end
    
    meta ={
      next_page: @user_role.next_page,
      prev_page: @user_role.prev_page,
      current_page: @user_role.current_page,
      total_pages: @user_role.total_pages
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

  def get_all
    
    datax = []

    @user_role = UserRole.all
    if @user_role.present?
      @user_role.each do |item|
        array = {
          id: item.id.to_s,
          name_role: item.name_role.to_s,
          status: item.status
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

  # GET /user_roles/1
  def show
    render json: @user_role
  end

  # POST /user_roles
  def create
    begin
      data = {
        name_role: params['name_role'],
        status: params['status']
      }

      @user_role = UserRole.new(data)

      if @user_role.save
        result = {
            status: true,
            message: 'Berhasil Tambah User Role',
            content: @user_role
        }
      else
        result = {
            status: false,
            message: 'Gagal Tambah User Role!'
        }
      end
      render json: result
    rescue Exception => ex
      result = {
        status: false,
        message: "Gagal Tambah User Role! Error: #{ex}"
      }
      render json: result
    end
  end

  # PATCH/PUT /user_roles/1
  def update
    begin
      user_role = UserRole.find(params['id'])
      if user_role.present?

        user_role.name_role = params['name_role']
        user_role.status = params['status']
        update = user_role.save

        if update
          result = {
            status: true,
            message: 'Sukses Ubah User Role'
          }
        else
          result = {
            status: false,
            message: 'Gagal Ubah User Role!'
          }
        end
      else
        result = {
            status: false,
            message: 'User Role Tidak ditemukan!'
          }
      end
      render json: result

    rescue Exception => ex
      result = {
        status: false,
        message: "Gagal Ubah User Role! Error: #{ex}"
      }
      render json: result
    end
  end

  # DELETE /user_roles/1
  def destroy
    @user_role.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_role
      @user_role = UserRolesServices.new
    end

    # Only allow a trusted parameter "white list" through.
    def user_role_params
      params.permit(:id, :name_role, :id_role, :status)
    end
end
