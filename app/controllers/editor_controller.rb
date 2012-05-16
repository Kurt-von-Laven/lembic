class EditorController < ApplicationController
  
  def equations
    if !params.nil?
      new_equation = params[:new_equation]
      new_constant_array = params[:new_constant_array]
      if !(new_equation.nil?)
        Variable.create_from_form(new_equation)
      elsif !(new_constant_array.nil?)
        Variable.create_constant_array(new_constant_array)
      end
    end
    @variables = Variable.order(:name)
    render 'equations'
  end
  
  def delete_variable
    if !params.nil?
      variable_id = params[:id] # TODO: Check that this ID is valid.
      if !(variable_id.nil?)
        Variable.delete(variable_id)
      end
    end
    @variables = Variable.order(:name)
    redirect_to '/editor/equations'
  end
  
  def delete_relationship
    if !params.nil?
      variable_id = params[:id] # TODO: Check that this ID is valid.
      if !(variable_id.nil?)
        Variable.update(variable_id, {:expression_string => nil, :expression_object => nil})
      end
    end
    @variables = Variable.order(:name)
    redirect_to '/editor/equations'
  end
  
end
