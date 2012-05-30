require 'yaml'
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
        input_values_hash[varname][:formula] = YAML::load(expression_object) unless expression_object.nil?
        input_values_hash[varname][:index_names] = index_names if index_names
      end
      if variable_to_solve_for.nil?
        if vars['variable_to_solve_for'].nil?
          flash[:evaluator_error] = 'Variable to solve for can\'t be blank.' # TODO: Check for this case at the beginning of the function.
        else
          flash[:evaluator_error] = "You tried to solve for the variable #{vars['variable_to_solve_for']}, but that variable doesn't exist."
        end
      else
        if variable_to_solve_for.array?
          min_index = vars['min_index'].to_i
          max_index = vars['max_index'].to_i
          variables_to_solve_for = [{:name => variable_to_solve_for.name, :indices => {:min => min_index, :max => max_index}}]
        else
          variables_to_solve_for = [{:name => variable_to_solve_for.name}]
        end
        evaluator = Evaluator.new
        logger.debug(variables_to_solve_for.inspect)
        logger.debug(input_values_hash.inspect)
        evaluator.eval_all(variables_to_solve_for, input_values_hash)
        @output_variables = input_values_hash
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
    #temporary method to make sure the index names table is working by getting the index names from multiple sources
    variable_name_components = variable.name.split(/[\[\]]/)
    #index_names_string = variable_name_components[1]
    index_names_from_table = variable.index_names().order("position").collect { |i| i.name }
    #if index_names_string
    #  index_names = index_names_string.split(',')
    #else
    #  index_names = nil
    #end
    #if !index_names.nil? && index_names_from_table[0].nil?
    #  raise "index names didn't work.  Variable had index names #{index_names_string}, but index names table had nothing."
    #end
    #if index_names_string.to_s != index_names_from_table.join(",")
    #  raise "index names didn't match.  Variable had index names #{index_names_string.inspect}, but index names table had #{index_names_from_table.join(",").inspect}."
    #end
    if index_names_from_table.length == 0
      return nil
    end
    return index_names_from_table
  end
  
  def to_i_safely(str)
    return nil unless str.instance_of?(String)
    return 0 if str == '0'
    str_as_integer = str.to_i
    return (str_as_integer == 0) ? nil : str_as_integer
  end

  
end
