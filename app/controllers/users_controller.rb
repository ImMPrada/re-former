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
  rescue ActiveRecord::RecordNotFound
    remove_unexisting_user_frame
  end

  def update
    @user = User.find(user_id)

    if @user.update(user_params)
      respond_to { |format| update_user(format) }
    else
      respond_to { |format| errors_notice(format, @user.errors.full_messages) }
    end
  end

  def destroy
    @user = User.find(user_id)

    @user.destroy
    respond_to do |format|
      remove_user(format)
      format.html { redirect_to users_path, notice: 'Users updated' }
    end
  end

  private

  def errors_notice(format, errors_messages)
    format.turbo_stream do
      render turbo_stream: [
        turbo_stream.update(:notice,
                            partial: 'errors',
                            locals: { errors_messages: })
      ]
    end
  end

  def update_user(format)
    format.turbo_stream do
      render turbo_stream: [
        turbo_stream.replace(@user, partial: 'user', locals: { user: @user }),
        turbo_stream.update(:notice, partial: 'success')
      ]
    end
    format.html { redirect_to users_path, notice: 'User was successfully updated.' }
  end

  def remove_user(format)
    @users = User.all

    if @users.empty?
      replace_users_list(format)
    else
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@user), turbo_stream.update(:notice, partial: 'success')
        ]
      end
    end
  end

  def replace_users_list(format)
    format.turbo_stream do
      render turbo_stream: [
        turbo_stream.replace(:users_list,
                             partial: 'users',
                             locals: { users: @users })
      ]
    end
  end

  def remove_unexisting_user_frame
    render turbo_stream: [
      turbo_stream.remove("user_#{user_id}".to_sym),
      turbo_stream.update(:notice,
                          partial: 'errors',
                          locals: { errors_messages: ['User did not exist, index updated'] })
    ]
  end

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end

  def user_id
    params.require(:id)
  end
end
