class EditorController < ApplicationController
  
  def equations
    if !params.nil?
      if !(params[:new_equation].nil?)
        new_equation = params[:new_equation]
        Variable.create_from_form(new_equation)
      end
    end
    @variables = Variable.order(:name)
    render 'equations'
  end
  
  def delete_variable
    if !params.nil? and !(params[:id].nil?)
      Variable.delete(params[:id]) # TODO: Check that this ID is valid.
    end
    @variables = Variable.order(:name)
    redirect_to '/editor/equations'
  end
  
  def delete_relationship
    if !params.nil? and !(params[:id].nil?)
      Variable.update(params[:id], {:expression_string => nil, :expression_object => nil})
      redirect_to '/editor/equations'
    end
  end
  
end
