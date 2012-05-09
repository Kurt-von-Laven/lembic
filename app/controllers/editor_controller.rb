class EditorController < ApplicationController
  
  def home
    # Do nothing.
  end
  
  def variables
    if !params.nil? and !(params[:new_var].nil?)
      Variable.create_from_form(params[:new_var])
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
  
  
  def delete_variable
    if !params.nil? and !(params[:id].nil?)
      Variable.delete(params[:id]) # TODO: Check that this ID is valid.
    end
    @variables = Variable.find(:all)
    redirect_to request.referer # TODO: This is not a robust way to redirect the user to the page they were on.
  end
  
  def delete_relationship
    if !params.nil? and !(params[:id].nil?)
      Variable.update(params[:id], {:expression_string => nil, :expression_object => nil})
      redirect_to '/editor/equations'
    end
  end
  
end
