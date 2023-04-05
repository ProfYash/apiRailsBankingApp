class UsersController < ApplicationController
  before_action :newSession, only: [:login]
  before_action :check_user_is_admin, only: [:update, :destroy]
  before_action :update_user_balance, only: [:show, :update]

  def login
    username = params[:username]
    password = params[:password]
    if !(username && password)
      render json: {
               status: { code: 400, message: "Username or Password Empty" },
             }, status: :unprocessable_entity
      return
    end
    userToCheck = find_user_by_username(username)
    puts userToCheck.inspect
    if !userToCheck
      render json: {
               status: { code: 400, message: "User Not Found" },
             }, status: :unauthorized
      return
    end
    if userToCheck.password != password
      render json: {
               status: { code: 400, message: "Password Incorrect" },
             }, status: :unauthorized
      return
    end
    token = createToken(userToCheck)
    if !token
      render json: {
               status: { code: 400, message: "SignUp Invalid" },
             }, status: :unprocessable_entity
      return
    end
    puts "11111111111111111111@cookie_name1111111111111111"
    puts @cookie_name
    createCookie(@cookie_name, token)
    render json: {
             status: { code: 200, message: "SignIn Done", data: userToCheck },
           }, status: :ok
    return
  end

  def index
    # @users = User.all
    # render json: @users
    User.all.each do |user|
      total_balance = user.accounts.sum(:balance)
      user.update(total_balance: total_balance)
    end

    # Render the response with updated user data
    @users = User.all.includes(accounts: :bank)
    render json: @users.as_json(include: { accounts: {
                                  include: :bank,
                                } })
  end

  def show
    @user = User.includes(accounts: :banks).find(params[:id])
    render json: @user.as_json(include: { accounts: {
                                 include: :banks,
                               } })
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.where(id: params[:id]).first

    if @user.update(user_params)
      # head(:ok)
      render json: @user
    else
      head(:unprocessable_entity)
    end
  end

  def destroy
    @user = User.where(id: params[:id]).first
    if @user.destroy
      head(:ok)
    else
      head(:unprocessable_entity)
    end
  end

  private

  def find_user_by_username(username)
    user = User.all.where(username: username).first
    if user
      return user
    end
    return nil
  end

  def user_params
    params.require(:user).permit(:username, :password, :full_name, :is_admin, :total_balance)
  end

  def createToken(user)
    puts "11111111111111createToken1111111111111111"
    puts user.inspect
    jwt_token = JWT.encode(
      { id: user.id, is_admin: user.is_admin, full_name: user.full_name },
      Rails.application.credentials.fetch(:secret_key_base)
    )
    puts "1111111111111jwt_token11111111111111111111"
    puts jwt_token
    return jwt_token
  end

  def createCookie(name, value)
    puts "createCookie111111111111111111111"
    puts name, value
    cookies[name] = {
      :value => value,
      :expires => 1.year.from_now,
    }

    puts "cookies[name]1111111111111111"
    puts cookies[name]
  end

  def newSession
    @cookie_name = "BankApp_Auth"
    @cookie_session = " _bankApp_session"
    @cookie_session_id = " _session_id"
    cookies.delete @cookie_name
    cookies.delete @cookie_session_id
    cookies.delete @cookie_session
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

  def update_user_balance
    @user = User.find(params[:id])
    total_balance = @user.accounts.sum(:balance)
    @user.update(total_balance: total_balance)
  end
end
