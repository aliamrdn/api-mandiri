require 'jwt_lib'
class UsersController < ApplicationController
  before_action :authenticate, except: [:login]
  # before_action :set_user

  # GET /users
  def index
    # @users = User.all
    # render json: @users
    datax = []
    @page = params["page"].present? ? params["page"].to_i : 1
    @limit = params["limit"].present? ? params["limit"].to_i : 5
    @keyword = params['keyword']

    if params['keyword'].present?
      @user = User.where(:email => @keyword).page(@page).per(@limit)
    else 
      @user = User.all.page(@page).per(@limit)
    end
    
    if @user.present?
      @user.each do |item|
        userrole = UserRole.find(item.role_user)
        array = {
          id: item.id.to_s,
          email: item.email,
          name: item.name,
          role_user: item.role_user,
          role_user_name: userrole['name_role'],
          status: item.status
        }
        datax.push(array)
      end
    end
    
    meta ={
      next_page: @user.next_page,
      prev_page: @user.prev_page,
      current_page: @user.current_page,
      total_pages: @user.total_pages
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

    @user = User.all
    if @user.present?
      @user.each do |item|
        userrole = UserRole.find(item.role_user)
        array = {
          id: item.id.to_s,
          email: item.email,
          name: item.name,
          role_user: item.role_user,
          role_user_name: userrole['name_role'],
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

  # GET /check/1
  def login
     app_token = params[:app_token]
     password = Digest::MD5.hexdigest(params[:password])
        @user = User.find_by(email: params[:email], password: password)
        user_role = UserRole.find(@user.role_user)
        if @user.present?
            token = JwtLib.encode(user_id: @user.id)
            render json: { status: true, message: 'authenticated', 
                            content: {token: token, exp: Time.now.to_i + 10800, email: @user.email, id_role: @user.role_user, user_role: user_role.name_role }
                        }, status: :ok
        elsif 
          
            render json: { status: false, message: 'unauthorized', content: nil }, status: :unauthorized
        end
  end
  # GET /users/1
  def show
    data = @user.find(user_params)
    render json: data
  end

  # POST /users
  def create
    begin
      password = Digest::MD5.hexdigest(params['password'])

      data = {
        email: params['email'],
        name: params['name'],
        password: password,
        status: params['status'],
        role_user: params['role_user']
      }

      @user = User.new(data)

      if @user.save
        result = {
            status: true,
            message: 'Berhasil Tambah User',
            content: @modul
        }
      else
        result = {
            status: false,
            message: 'Gagal Tambah User!'
        }
      end
      render json: result
    rescue Exception => ex
      result = {
        status: false,
        message: "Gagal Tambah User! Error: #{ex}"
      }
      render json: result
    end
  end

  # PATCH/PUT /users/1
  def update
    begin
      user = User.find(params['id'])
      if user.present?
        passwords = Digest::MD5.hexdigest(params['password'])
        user.email = params['email']
        user.name = params['name']
        user.password = passwords
        user.status = params['status']
        user.role_user = params['role_user']
        update = user.save

        if update
          result = {
            status: true,
            message: 'Sukses Ubah User'
          }
        else
          result = {
            status: false,
            message: 'Gagal Ubah User!'
          }
        end
      else
        result = {
            status: false,
            message: 'User Tidak ditemukan!'
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
    # update_user = @user.update(user_params)
    # render json: update_user

  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_user
    #   @user = LoginServices.new
    # end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.permit(:id, :email, :name, :password, :status, :role_user)
    end
end
