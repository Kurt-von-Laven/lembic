class ModelsController < ApplicationController
  
  skip_before_filter :verify_model, :only => ["create", "new"]
  def index
    @models = Model.all # TODO: only load models for which this user has a valid model_permission
  end

  def new
    @model = Model.new
  end

  def create
    @model = Model.new(params["model"])
    save_successful = false
    ActiveRecord::Base.transaction do
      save_successful = @model.save
      model_permissions = ModelPermission.new({:user_id => session[:user_id],
                                                :model_id => @model.id, :sort_index => User.find(session[:user_id]).models.length, :permissions => 0})
      save_successful &&= model_permissions.save
    end
    if save_successful
      redirect_to :action => "index", :notice => 'Model was successfully created.'
      session[:model_id] = @model.id
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
    @model = Model.find(params[:id])
    
    if @model.update_attributes(params[:model])
      redirect_to @model, :notice => 'Model was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @model = Model.find(params[:id])
    @model.destroy
    
    redirect_to models_path
  end
end
