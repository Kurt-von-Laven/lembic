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
      variable = Variable.where(:id => params[:id]).first
      if !variable.nil?
        variable.destroy()
      end
    end
    redirect_to :action => 'equations'
  end
  
  def delete_relationship
    if !params.nil?
      variable = Variable.where(:id => params[:id]).first
      if !variable.nil?
        variable.expression_string = nil
        variable.expression_object = nil
        variable.save
      end
    end
    redirect_to :action => 'equations'
  end
  
end
