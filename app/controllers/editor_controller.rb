class EditorController < ApplicationController
  def home
    # No changes
  end
  
  def variableeditor
    if !params.nil? and !(params[:new_var].nil?)
      new_variable(params[:new_var])
    end
    @variables = Variable.find(:all)
    render 'variableeditor'
  end
  
  def new_variable(vari)
    vari['workflow_id'] = 1 # TODO: Grab the workflow ID out of the session state.
    Variable.new(vari)
  end
  
end
