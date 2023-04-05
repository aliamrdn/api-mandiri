class AppsController < ApplicationController
  before_action :set_app, only: [:show, :update, :destroy]

  # GET /apps
  def index
    @apps = App.all

    render json: @apps
  end

  # GET /apps/1
  def show
    render json: @app
  end

  # POST /apps
  def create

    @app = App.new(app_params)

    if @app.save
      render json: @app, status: :created, location: @app
    else
      render json: @app.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /apps/1
  def update
    if @app.update(app_params)
      render json: @app
    else
      render json: @app.errors, status: :unprocessable_entity
    end
  end

  # DELETE /apps/1
  def destroy
    @app.destroy
  end

  def request_token

    if token_params[:id].present? && token_params[:secret].present?

      app = App.find(token_params[:id])

      if app.present? && app.status == 1 && app.secret == token_params[:secret]
          
        # --------------------------------------------
        # READ SYSTEM SETTINGS
        # --------------------------------------------
        sys_setting = SystemSetting.find_by(sys_key: 'allow_request_token_after')
        sys_setting2 = SystemSetting.find_by(sys_key: 'session_token_expired')
        allow_request_token_after = (sys_setting.sys_val.to_i) rescue 0
        session_token_expired = (sys_setting2.sys_val.to_i) rescue 0
        
        # --------------------------------------------
        # CHECK IF TOKEN EXISTS
        # --------------------------------------------
        cek_token = Session.where(app_id: app.id).last
        if cek_token.present?
          
          cek_token_exp = Time.parse(cek_token.expired_time)

          diff_time = Time.now - cek_token_exp
		  
          if diff_time > 0
            expired_time = (Time.now + session_token_expired.seconds).strftime('%Y-%m-%d %H:%M:%S')
            token = SecureRandom.uuid
            save_token = generate_token(app.id, expired_time, token)

            if save_token
              render json: {status: true, message: "Request App Token OK!", token: token, expired_time: expired_time}
            else
              render json: {status: false, message: "Request App Token Failed! try again later...", token: "", expired_time: ""}
            end
          else
            render json: {status: true, message: "Request App Token OK!", token: cek_token.token, expired_time: cek_token.expired_time}
          end
        # --------------------------------------------
        # IF TOKEN DOESN'T EXISTS
        # --------------------------------------------
        else
          expired_time = (Time.now + session_token_expired.seconds).strftime('%Y-%m-%d %H:%M:%S')
          token = SecureRandom.uuid
          save_token = generate_token(app.id, expired_time, token)

          if save_token
            render json: {status: true, message: "Request App Token OK!", token: token, expired_time: expired_time}
          else
            render json: {status: false, message: "Request App Token Failed! try again later...", token: "", expired_time: ""}
          end
        end
        # --------------------------------------------

      else
        render json: {status: false, message: "Request App Token Failed!\nInvalid Application.", token: "", expired_time: ""}
      end
    else
      render json: {status: false, message: "Request App Token Failed!\nInvalid parameters.", token: "", expired_time: ""}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app
      @app = App.find(params[:id])

    end

    # Only allow a trusted parameter "white list" through.
    def app_params
      params.require(:app).permit(:id, :name, :secret, :status)
    end

    def token_params
      params.permit(:id, :name, :secret, :status)
    end

    def generate_token(app_id, expired_time, token)
      param_token = {app_id: app_id,expired_time: expired_time, token: token}
      save_token = Session.new(param_token)
      save_token.save
    end
end
