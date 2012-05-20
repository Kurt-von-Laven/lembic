class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :verify_login
  
  def verify_login
    if User.where(:id => session[:user_id]).empty?
      redirect_to login_path
    end
  end
  
  def verify_logout
    if !User.where(:id => session[:user_id]).empty?
      redirect_to home_path
    end
  end
  
end
