class PencairansController < ApplicationController
  before_action :authenticate, except: [:index]
  before_action :set_pencairan

  # GET /pencairans
  def index
    @pencairans = Pencairan.all

    render json: @pencairans
  end

  # GET Data Approval Untuk Dept Head
  def get_approval_depthead

    data = @pencairan.get_data_approval_depthead(pencairan_params)
    render json: data
    
  end

  # GET /pencairans/1
  def show
    render json: @pencairan
  end

  # POST /pencairans
  def create

    create_pencariran = @pencairan.add(pencairan_params)
    render json: create_pencariran 
  end

  # PATCH/PUT /pencairans/1
  def update
    # render json: params
    # return

    edit_pencariran = @pencairan.update(pencairan_params)
    render json: edit_pencariran 

  end

  #by id
  def get_by_id

    @pencairan = Pencairan.where(underlying_id: params[:underlying_id])
    render json: {status: true, content: @pencairan}

  end


  # DELETE /pencairans/1
  def destroy
    @pencairan.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pencairan
      @pencairan = PencairanServices.new
    end

    # Only allow a trusted parameter "white list" through.
    def pencairan_params
      params.permit(:id, :underlying_id, :id_pengajuan, :comp_id, :created_at, :total_data, :total_plafond, :total_outstanding, :status, :file_status, :file_name, :id_generate, :underlying_name, :nominal_pencairan, :nopk, :status_approve, :last_user_approve, :last_date_approve)
    end
end
