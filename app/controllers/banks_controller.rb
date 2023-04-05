class BanksController < ApplicationController
  before_action :check_user_is_admin, only: [:update, :destroy, :create]

  before_action :set_bank, only: [:show, :update, :destroy]

  # GET /users/:user_id/banks
  def index
    @banks = Bank.all
    render json: @banks
  end

  # GET /users/:user_id/banks/:id
  def show
    render json: @bank
  end

  # POST /users/:user_id/banks
  def create
    @bank = Bank.create(bank_params)
    if @bank.persisted?
      render json: @bank, status: :created
    else
      render json: @bank.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:user_id/banks/:id
  def update
    if @bank.update(bank_params)
      render json: @bank
    else
      render json: @bank.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/banks/:id
  def destroy
    @bank.destroy
  end

  private

  def set_bank
    @bank = Bank.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def bank_params
    params.require(:bank).permit(:full_name, :abbrv)
  end

  def check_user_is_admin
    @jwt_payload = getPayload()
    puts "***************check_user_is_admin********************"
    puts @jwt_payload
    if (!@jwt_payload["is_admin"])
      render json: {
               status: { code: 400, message: "Admin Login Needed to CUD Bank Only Read Allowed" },
             }, status: :unauthorized
      return
    end
  end

  def getPayload
    token = cookies["BankApp_Auth"]
    if !token
      render json: {
               status: { code: 400, message: "cookies Not Found" },
             }, status: :unauthorized
      return
    end
    payload = JWT.decode(token, Rails.application.credentials.fetch(:secret_key_base)).first

    if !payload
      render json: {
               status: { code: 400, message: "payload Not decodeable" },
             }, status: :unauthorized
      return
    end

    return payload
  end
end
