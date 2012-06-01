require Rails.root.join('app/helpers/expression')

class WorkflowController < ApplicationController
  
  def evaluate
    @variables = Variable.where(:workflow_id => session[:user_id]).order(:name)
    @input_variables = Variable.where(:workflow_id => session[:user_id], :expression_string => nil).order(:name)
    vars = params[:evaluator]
    if !vars.nil?
      input_values = vars['input_values']
      input_values_hash = {}
      i = 0
      for input_value in input_values
        input_value_as_integer = to_i_safely(input_value)
        input_value = (input_value_as_integer.nil?) ? input_value : input_value_as_integer
        input_values_hash[@input_variables[i].name] = {:value => input_value}
        i += 1
      end
      variable_to_solve_for = Variable.where(:name => vars['variable_to_solve_for']).first
      Variable.find(:all).each do |variable|
        expression_object = variable.expression_object
        varname = variable.name.split(/\s*\[/)[0]
        index_names = get_index_names(variable)
        input_values_hash[varname] ||= {}
        input_values_hash[varname][:formula] = expression_object unless expression_object.nil?
        input_values_hash[varname][:index_names] = index_names if index_names
      end
      if variable_to_solve_for.nil?
        if vars['variable_to_solve_for'].nil?
          flash[:evaluator_error] = 'Variable to solve for can\'t be blank.' # TODO: Check for this case at the beginning of the function.
        else
          flash[:evaluator_error] = "You tried to solve for the variable #{vars['variable_to_solve_for']}, but that variable doesn't exist."
        end
        @output_variables = []
      else
        name_of_variable_to_solve_for = vars['variable_to_solve_for'].split(/\s*\[/)[0]
        if variable_to_solve_for.array?
          min_index = vars['min_index'].to_i
          max_index = vars['max_index'].to_i
          variables_to_solve_for = [{:name => name_of_variable_to_solve_for, :indices => {:min => min_index, :max => max_index}}]
        else
          variables_to_solve_for = [{:name => name_of_variable_to_solve_for}]
        end
        evaluator = Evaluator.new
        evaluator.eval_all(variables_to_solve_for, input_values_hash)
        
        #get evaluator output
        @output_variables = {}
        logger.debug(input_values_hash.inspect)
        for variable_name, variable_properties in input_values_hash
          logger.debug(variable_properties.inspect)
          scalar_value = variable_properties[:value]
          if scalar_value.nil?
            #variable is an array
            array_value = variable_properties[:values]
            array = []
            if !array_value.nil?
              #populate array with the output values
              for indices, value in array_value
                if indices.length == 1
                  array[indices[0] - 1] = value # TODO: Handle multi-dimensional arrays.
                else
                  raise "multidimensional variable output not supported"
                end
              end
              @output_variables[variable_name] = array.inspect
            end
          elsif scalar_value != ''
            #variable is a scalar
            @output_variables[variable_name] = scalar_value
          end
        end
      end
    else
      @output_variables = []
    end
    render 'evaluator'
  end
  
  def expert_workflow
    
  end
  
  private
  
  def get_index_names(variable)
    return variable.index_name_strings
  end
  
  def to_i_safely(str)
    return nil unless str.instance_of?(String)
    return 0 if str == '0'
    str_as_integer = str.to_i
    return (str_as_integer == 0) ? nil : str_as_integer
  end

  
end
