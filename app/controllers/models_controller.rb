class ModelsController < ApplicationController
  def index
    @models = Model.all # TODO: only load models for which this user has a valid model_permission
  end

  def new
    @model = Model.new
  end

  def create
    @model = Model.new(params[:model])
    
    if @model.save
      redirect_to @model, :notice => 'Model was successfully created.'
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
