class ApplicationController < ActionController::Base
  protect_from_forgery
    layout "application"
  
  before_filter :prevent_caching, :verify_login, :verify_model
  
  def prevent_caching
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Thu, 01 Jan 1970 00:00:00 GMT'
  end
  
  def verify_login
    if User.where(:id => session[:user_id]).empty?
      redirect_to login_path
    end
  end
  
  def verify_model
    if session[:model_id].nil?
      session[:model_id] = User.find(session[:user_id]).models.first
      if session[:model_id].nil?
        redirect_to :controller => "models", :action => "new"
      end
    end
  end
  
  def verify_logout
    if !User.where(:id => session[:user_id]).empty?
      redirect_to home_path
    end
  end
  
  def user_models
    @user_models = User.find(session[:user_id]).models.sort
  end
  
  def set_current_model
    new_model_id = params[:model_id]
    new_model = ModelPermission.where(:user_id => session[:user_id], :model_id => new_model_id).first
    if new_model.nil?
      flash[:invalid_model_id] = 'You tried to select a model that either doesn\'t exist or that you don\'t have permission to see.'
    else
      session[:model_id] = new_model_id
    end
    @user_models = User.find(session[:user_id]).models.sort
  end
  
end
