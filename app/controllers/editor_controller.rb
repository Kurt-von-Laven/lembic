class EditorController < ApplicationController
  def home
    # No changes
  end
  
  def variableeditor
    new_variable(params[:new_var])
    @variables = Variable.find(:all)
    render 'variableeditor'
  end
  
  def new_variable(var)
    var[:workflow_id] = 1 # TODO: Grab the workflow ID out of the session state.
    Variable.new(var)
  end
  
end
