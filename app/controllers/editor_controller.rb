class EditorController < ApplicationController
  
  DEFAULT_OPTIONS = {'workflow_id' => 1, 'array' => false, 'const' => false} # TODO: Grab the workflow ID out of the session state.
  
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
  
  def new_variable(var)
    p = Permission.first_or_create({'user_id' => 1, 'workflow_id' => 1, 'permissions' => 4})
    # u = User.first_or_create('')
    w = Workflow.first_or_create({'name' => 'Sample Workflow', 'description' => 'This record should be removed eventually and is just for test purposes.'})
    merged_var = DEFAULT_OPTIONS.merge(var)
    puts "WHAT IS GOING ON???"
    puts merged_var.inspect
    v = Variable.new(merged_var)
    puts v.save
  end
  
end
