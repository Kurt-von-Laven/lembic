class ModelsController < ApplicationController
  
  skip_before_filter :verify_model, :only => ["create", "new"]
  skip_before_filter :verify_workflow
  
  def index
    @models = User.find(session[:user_id]).models
  end

  def new
    @model = Model.new
  end

  def create
    @model = Model.new(params["model"])
    save_successful = false
    ActiveRecord::Base.transaction do
      save_successful = @model.save!
      model_permission = ModelPermission.new({:user_id => session[:user_id],
                                               :model_id => @model.id, :sort_index => User.find(session[:user_id]).model_permissions.length, :permissions => 0})
      save_successful &&= model_permission.save!
    end
    if save_successful
      session[:model_id] = @model.id
      redirect_to :action => "index", :notice => 'Model was successfully created.'
    else
      render :action => "new"
    end
  end

  def show
    @model = Model.find(params[:id])
  end

  def edit
    @model = Model.find(params[:id])
  end

  def update
    Model.transaction do
      @model = Model.find(params[:id])
      update_successful = @model.update_attributes!(params[:model])
    end
    if update_successful
      redirect_to @model, :notice => 'Model was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @model = Model.find(params[:id])
    @model.destroy
    if session[:model_id] == params[:id].to_i
      session[:model_id] = nil
    end
    redirect_to models_path
  end
  
  def set_current
    model_hash = params[:model]
    if !model_hash.nil?
      new_model_id = model_hash[:id]
      new_model_permission = ModelPermission.where(:user_id => session[:user_id], :model_id => new_model_id).first
      if new_model_permission.nil?
        flash[:invalid_model_id] = 'You tried to select a model that either doesn\'t exist or that you don\'t have permission to use.'
      else
        session[:model_id] = new_model_id
      end
    end
    redirect_to :back
  end
  
end
