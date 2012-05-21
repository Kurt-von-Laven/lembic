class UserController < ApplicationController
  
  skip_before_filter :verify_login
  before_filter :verify_logout, :except => ['logout']
  
  def login
    login_form = params[:user]
    if !login_form.nil?
      email = login_form[:email]
      user = User.where(:email => email).first
      candidate_password = login_form[:password]
      if !user.nil? and !candidate_password.nil? and user.password_valid?(candidate_password)
        session[:user_id] = user.id
        redirect_to home_path
        return
      end
      flash[:wrong_login] = 'The email address or password you entered is incorrect.'
    end
    render 'login'
  end
  
  def logout
    session.clear
    redirect_to login_path
  end
  
  def register
    registration_form = params[:user]
    if !registration_form.nil?
      @user = User.new(:first_name => registration_form[:first_name],
                       :last_name => registration_form[:last_name],
                       :email => registration_form[:email],
                       :organization => registration_form[:organization])
      password = registration_form[:password]
      password_confirmation = registration_form[:password_confirmation]
      @user.password = password
      @user.valid? # Populate error messages.
      if password.length < User::MINIMUM_PASSWORD_LENGTH
        @user.errors.add(:password, "is too short (minimum is #{User::MINIMUM_PASSWORD_LENGTH} characters)")
      end
      if password == password_confirmation
        is_valid = @user.save
        if password.length < User::MINIMUM_PASSWORD_LENGTH
          @user.errors.add(:password, "is too short (minimum is #{User::MINIMUM_PASSWORD_LENGTH} characters)")
        end
        if is_valid
          flash[:account_created] = 'Your account was successfully created.'
          redirect_to login_path
          return
        end
      else
        @user.errors.add(:password_confirmation, 'didn\'t match')
      end
    else
      @user = User.new
    end
    render 'register'
  end
  
end
