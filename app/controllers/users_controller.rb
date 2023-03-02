class UsersController < ApplicationController
  USERNAME_PLACEHOLDER = 'write how you wanna be called'
  PASSWORD_PLACEHOLDER = 'numbers and letters only'
  EMAIL_PLACEHOLDER = 'example@example.com'

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to new_user_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end
end
