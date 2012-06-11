require 'cgi'

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :prevent_caching, :verify_login, :verify_model, :verify_workflow, :authenticity_token, :user_models, :model_workflows
  
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
      session[:model_id] = Model.joins(:model_permissions).where('(model_permissions.user_id = ?) AND (model_permissions.sort_index = 0)',
                                                                 session[:user_id]).pluck(:model_id).first
      if session[:model_id].nil?
        redirect_to :controller => 'models', :action => 'new'
      end
    end
  end
  
  def verify_workflow
    if session[:workflow_id].nil?
      model = Model.where(:id => session[:model_id]).first
      if !model.nil?
        Workflow.transaction do
          session[:workflow_id] = model.workflows.where(:sort_index => 0).pluck(:id).first
          if session[:workflow_id].nil?
            redirect_to :controller => 'view_editor', :action => 'edit_block'
          end
        end
      end
    end
  end
  
  def verify_logout
    if !User.where(:id => session[:user_id]).empty?
      redirect_to home_path
    end
  end
  
  def authenticity_token
    @authenticity_token = (session[:_csrf_token].nil?) ? '' : CGI::escape(session[:_csrf_token])
  end
  
  def user_models
    @models = Model.joins(:model_permissions).where('model_permissions.user_id = ?', session[:user_id]).order(:sort_index)
  end
  
  def model_workflows
    model = Model.where(:id => session[:model_id]).first
    if !model.nil?
      @workflows = model.workflows.order(:sort_index)
    end
  end
  
end
