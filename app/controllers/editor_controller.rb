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
    @variables = Variable.where(:model_id => user_id).order(:name)
    render 'equations'
  end
  
  def find_variablenames
    # TODO: This will break if params[:term] contains a percent symbol. It needs to use escaping.
    @variablenames = Variable.where('(:model_id = ?) AND (name LIKE ?)', session[:user_id], "#{params[:term]}%").order(:name)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def variable
    variable_form = params[:variable]
    if !variable_form.nil?
      variable_name = variable_form[:name]
      expression_string = variable_form[:expression_string]
      variable_record = Variable.where(:id => variable_form[:id]).first
      if variable_record.nil?
        flash[:unrecognized_variable] = "The variable you tried to edit, #{variable_name}, was probably recently" +
          " deleted by a member of your team. Your equation, #{expression_string}, was not saved."
      else
        variable_record.name = variable_name
        variable_record.expression_string = expression_string
        logger.debug(variable_record.expression_string)
        if !variable_record.save
          flash[:variable_errors] = variable_record.errors.full_messages
        end
      end
    end
    redirect_to :back
  end
  
  def delete_variable
    variable = Variable.where(:id => params[:id], :model_id => session[:user_id]).first
    if !variable.nil?
      variable.destroy
    end
    redirect_to :back
  end
  
  def delete_relationship
    variable = Variable.where(:id => params[:id], :model_id => session[:user_id]).first
    if !variable.nil?
      variable.expression_string = nil
      variable.save
    end
    redirect_to :back
  end
  
  def full_variable
    @var = Variable.where(:name => params[:name], :model_id => session[:user_id]).first
  end
  
end
