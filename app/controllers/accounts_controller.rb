class AccountsController < ApplicationController
  before_action :check_user
  before_action :set_user
  before_action :set_account, only: [:show, :update, :destroy]
  before_action :set_params_for_any_transactions, only: [:transfer, :withdraw, :deposit]
  before_action :check_sufficeint_balance, only: [:transfer, :withdraw]
  after_action :update_user_balance, only: [:create, :tranfer, :withdraw, :desposit]
  # GET /users/:user_id/accounts
  def index
    @accounts = @user.accounts
    render json: @accounts
  end

  # GET /users/:user_id/accounts/:id
  def show
    render json: @account.as_json(include: :banks)
  end

  # POST /users/:user_id/accounts
  def create
    @account = @user.accounts.build(account_params)
    if @account.save
      render json: @account, status: :created, location: user_account_url(@user, @account)
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:user_id/accounts/:id
  def update
    if @account.update(account_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/accounts/:id
  def destroy
    @account.destroy
  end

  def transfer
    ActiveRecord::Base.transaction do
      @from_account.balance -= @amount
      @to_account.balance += @amount
      if @from_account.save && @to_account.save
        render json: { message: "Transfer successful" }, status: :ok
      else
        render json: { message: "Transfer failed" }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
        return
      end
    end
  end

  def withdraw
    @from_account["balance"] -= @amount
    if @from_account.save
      render json: { message: "Withdraw successful" }, status: :ok
    else
      render json: { message: "Withdraw failed" }, status: :unprocessable_entity
    end
  end

  def deposit
    @from_account["balance"] += @amount
    if @from_account.save
      render json: { message: "Deposit successful" }, status: :ok
    else
      render json: { message: "Deposit failed" }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.

  def set_user
    @user = User.find(@jwt_payload["id"])
  end

  def set_account
    @account = @user.accounts.includes(:banks).find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def account_params
    params.require(:account).permit(:balance, :nick_name, :bank_id)
  end

  def check_user
    @jwt_payload = getPayload()
    if (@jwt_payload["id"].to_i != params[:user_id].to_i)
      render json: {
               status: { code: 400, message: "params user not matching with payload cookie Found" },
             }, status: :unauthorized
      return
    end
  end

  def update_user_balance
    total_balance = @user.accounts.sum(:balance)
    @user.update(total_balance: total_balance)
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

  def set_params_for_any_transactions
    puts "set_params_for_any_transactions1111111111111111111111111111"
    @from_account_id = params[:account_id]
    @to_account_id = params["to_account_id"]
    @amount = params["amount"]
    if !@amount
      render json: {
        status: { code: 400, message: "amount Not Found" },
      }, status: :unauthorized
      return
    end
    @to_account = Account.find(@to_account_id)
    @from_account = Account.find(@from_account_id)
    puts "to_account111111111111111111111111111111111111@@@@@@@@@@2"
    puts @to_account.inspect
    puts "from_account1111111111111111111111111111111111@@@@@@@@22"
    puts @from_account.inspect
    if !@to_account
      render json: @to_account.errors, status: :unprocessable_entity
      return
    end
    if !@from_account
      render json: @from_account.errors, status: :unprocessable_entity
      return
    end
  end

  def check_sufficeint_balance
    if @from_account["balance"] < @amount
      render json: { message: "Insufficient Balance" }, status: :unprocessable_entity
      return
    end
  end
end
