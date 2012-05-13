class EditorController < ApplicationController
  
  def equations
    if !params.nil?
      new_equation = params[:new_equation]
      if !(new_equation.nil?)
        Variable.create_from_form(new_equation)
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
