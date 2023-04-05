class SystemSettingsController < ApplicationController
  before_action :set_system_setting, only: [:show, :update, :destroy]

  # GET /system_settings
  def index
    @system_settings = SystemSetting.all

    render json: @system_settings
  end

  # GET /system_settings/1
  def show
    render json: @system_setting
  end

  # POST /system_settings
  def create
    @system_setting = SystemSetting.new(system_setting_params)

    if @system_setting.save
      render json: @system_setting, status: :created, location: @system_setting
    else
      render json: @system_setting.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /system_settings/1
  def update
    if @system_setting.update(system_setting_params)
      render json: @system_setting
    else
      render json: @system_setting.errors, status: :unprocessable_entity
    end
  end

  # DELETE /system_settings/1
  def destroy
    @system_setting.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_system_setting
      @system_setting = SystemSetting.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def system_setting_params
      params.require(:system_setting).permit(:sys_key, :sys_val)
    end
end
