class UsersController < ApplicationController
  USERNAME_PLACEHOLDER = 'write how you wanna be called'.freeze
  PASSWORD_PLACEHOLDER = 'numbers and letters only'.freeze
  EMAIL_PLACEHOLDER = 'example@example.com'.freeze

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(user_id)
  end

  def update
    @user = User.find(user_id)

    respond_to do |format|
      if @user.update(user_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(@user,
                                partial: 'users/user',
                                locals: { user: @user })
          ]
        end
        format.html { redirect_to users_path, notice: "Message was successfully updated." }
      else
        format.html { redirect_to users_path }
      end
    end
  end

  def destroy
    User.find(destroy_id).destroy

    reload
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end

  def user_id
    params.require(:id)
  end
end
