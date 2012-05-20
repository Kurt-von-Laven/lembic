class EditorController < ApplicationController
  
  def equations
    user_id = session[:user_id]
    new_equation = params[:new_equation]
    if !new_equation.nil?
        begin
            Variable.create_from_form(new_equation, user_id)
        rescue ArgumentError => e
            flash[:variable_not_saved] = e.message
        else
            flash[:variable_saved] = 'Your variable was successfully saved.'
        end
    else
      new_constant_array = params[:new_constant_array]
      if !new_constant_array.nil?
        Variable.create_constant_array(new_constant_array, user_id)
      end
    end
    @variables = Variable.where(:workflow_id => user_id).order(:name)
    render 'equations'
  end
  
  def delete_variable
    variable = Variable.where(:id => params[:id], :workflow_id => user_id).first
    if !variable.nil?
      variable.destroy
    end
    redirect_to equations_path
  end
  
  def delete_relationship
    variable = Variable.where(:id => params[:id], :workflow_id => user_id).first
    if !variable.nil?
      variable.expression_string = nil
      variable.expression_object = nil
      variable.save
    end
    redirect_to equations_path
  end
  
end
