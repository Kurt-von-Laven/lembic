class EditorController < ApplicationController
  autocomplete :variable, :name
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
        begin
          Variable.create_constant_array(new_constant_array, user_id)
        rescue ArgumentError => e
          flash[:variable_not_saved] = e.message
        else
          flash[:variable_saved] = 'Your variable was successfully saved.'
        end
      end
    end
    @variables = Variable.where(:workflow_id => user_id).order(:name)
    render 'equations'
  end
  
  def find_variablenames
    @variablenames = Variable.where('(workflow_id = ?) AND (name LIKE ?)', session[:user_id], "#{params[:term]}%").order(:name)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def delete_variable
    variable = Variable.where(:id => params[:id], :workflow_id => session[:user_id]).first
    if !variable.nil?
      variable.destroy
    end
    redirect_to :back
  end
  
  def delete_relationship
    variable = Variable.where(:id => params[:id], :workflow_id => session[:user_id]).first
    if !variable.nil?
      variable.expression_string = nil
      variable.expression_object = nil
      variable.save
    end
    redirect_to :back
  end
  
  def full_variable
    @var = Variable.where(:name => params[:name], :workflow_id => session[:user_id]).first
  end
  
end
