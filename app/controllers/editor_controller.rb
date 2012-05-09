class EditorController < ApplicationController
  
  DEFAULT_OPTIONS = {'workflow_id' => 1, 'array' => 0} # TODO: Grab the workflow ID out of the session state.
  
  def home
    # No changes
  end
  
  def delete_variable
    puts 'Yo dawg.'
    puts params.inspect
    if !params.nil? and !(params[:id].nil?)
      Variable.delete(params[:id]) # TODO: Check that this ID is valid.
    end
    @variables = Variable.find(:all)
    redirect_to '/editor/variables'
  end
  
  def variables
    if !params.nil?
      if !(params[:new_var].nil?)
        create_from_form(params[:new_var])
      elsif !(params[:delete_var].nil?)
        puts @delete_var.inspect
        Variable.delete(@delete_var.id)
      end
    end
    @variables = Variable.find(:all)
  end
  
  def equations
    if !params.nil? and !(params[:new_relationship].nil?)
      new_relationship = params[:new_relationship]
      variable_name = new_relationship['name']
      expression_string = new_relationship['expression_string']
      Variable.where(:name => variable_name).update_all(:expression_string => expression_string)
    end
    @variables = Variable.find(:all)
    render 'equations'
  end
  
end
