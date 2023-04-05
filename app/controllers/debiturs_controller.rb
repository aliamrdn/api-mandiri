class DebitursController < ApplicationController
  before_action :authenticate, except: [:index]
  before_action :set_debitur

  # GET /debiturs
  def index
    @debiturs = Debitur.all

    render json: @debiturs
  end

  # GET /debiturs/1
  def show
    render json: @debitur
  end

  # POST /debiturs
  def create

    # render json: params
    # return

    @create_debitur = @debitur.add(debitur_params)
    render json: @create_debitur

  end

  # PATCH/PUT /debiturs/1
  def update

    # render json: params
    # return
    
    update_debitur = @debitur.update(debitur_params)
    render json: update_debitur

  end


  # DELETE /debiturs/1
  def destroy
    @debitur.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_debitur
      @debitur = DebiturServices.new
    end

    # Only allow a trusted parameter "white list" through.
    def debitur_params
      params.permit(:id, :namanasabah, :notakredit, :tujuanpenggunaan, :nama_rm, :no_hprm, :department, :kolektibilitas, :limitobligor)
    end
end
