class EditorController < ApplicationController
  autocomplete :variable, :name
  
  def select
    @models = Model.find(session[:model_id])
  end
  
  def equations
    model_id = session[:model_id]
    new_equation = params[:new_equation]
    if !new_equation.nil?
      begin
        Variable.create_from_form(new_equation, model_id)
      rescue ArgumentError => e
        flash.now[:variable_not_saved] = e.message
      else
        flash.now[:variable_saved] = 'Your variable was successfully saved.'
      end
    else
      new_constant_array = params[:new_constant_array]
      if !new_constant_array.nil?
        begin
          Variable.create_constant_array(new_constant_array, model_id)
        rescue ArgumentError => e
          flash.now[:variable_not_saved] = e.message
        else
          flash.now[:variable_saved] = 'Your variable was successfully saved.'
        end
      end
    end
    @variables = Variable.where(:model_id => model_id).order(:name)
    render 'equations'
  end
  
  def find_variable_names
    # TODO: This will break if params[:term] contains a percent symbol. It needs to use escaping.
    model_id = session[:model_id]
    @variable_names = Variable.where('(model_id = ?) AND (name LIKE ?)', model_id, "#{params[:term]}%").order(:name)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def variable
    variable_form = params[:variable]
    if !variable_form.nil?
      variable_name_with_indices = variable_form[:name_with_indices]
      expression_string = variable_form[:expression_string]
      variable_record = Variable.where(:id => variable_form[:id]).first
      if variable_record.nil?
        flash[:unrecognized_variable] = "The variable you tried to edit, #{variable_name}, was probably recently" +
          " deleted by a member of your team. Your equation, #{expression_string}, was not saved."
      else
        variable_record.name_with_indices = variable_name_with_indices
        variable_record.expression_string = expression_string
        if !variable_record.save
          flash[:variable_errors] = variable_record.errors.full_messages
        end
      end
    end
    redirect_to :back
  end
  
  def delete_variable
    variable = Variable.where(:id => params[:id], :model_id => params[:model_id]).first
    if !variable.nil?
      variable.destroy
    end
    redirect_to :back
  end
  
  def delete_relationship
    variable = Variable.where(:id => params[:id]).first
    if !variable.nil?
      logger.debug "+++++++++++Set expression string to nil"
      variable.expression_string = nil
      variable.save
    end
    redirect_to :back
  end
  
  def full_variable
    @var = Variable.where(:name => params[:name], :model_id => params[:model_id]).first
  end
  
end
