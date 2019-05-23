class SessionsController < ApplicationController
  before_action :not_logged_in, only: [:destroy]
  before_action :already_logged_in, only: [:new, :create]

  def new
    @user = User.new
    render :new
  end

  def create
    user = User.find_by_credentials(params[:user][:email], params[:user][:password])

    if user
      handle_login(user)
    else
      flash.now[:error] = 'Wrong email or password'
      @user = User.new(email: params[:user][:email])
      render :new
    end
  end

  def destroy
    user = current_user
    logout!(user) if user
  end

  private

  def handle_login(user)
    if user.activated
      login!(user)
      redirect_to user_url(user)
    else
      flash.now[:error] = 'Account requires activation'
      @user = user
      @url = activate_users_url(activation_token: @user.activation_token)
      render :new
    end
  end
end