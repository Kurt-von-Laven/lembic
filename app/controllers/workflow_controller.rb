require './app/helpers/expression'

class WorkflowController < ApplicationController
  
  def evaluate
    @variables = Variable.where(:workflow_id => session[:user_id]).order(:name)
    vars = params[:evaluator]
    if !vars.nil?
      input_values = eval(vars['input_values'])
      output_variables = eval(vars['output_variables'])
      for input_variable, input_formula in input_values
        input_values[input_variable] = {:value => input_formula}
      end
      Variable.find(:all).each do |variable|
        expression_object = variable.expression_object
        varname = variable.name.split(/\s*\[/)[0]
        index_names = get_index_names(variable)
        input_values[varname] ||= {}
        input_values[varname][:formula] = expression_object unless expression_object.nil?
        input_values[varname][:index_names] = index_names if index_names
      end
      evaluator = Evaluator.new
      evaluator.eval_all(output_variables, input_values)
      @results = input_values
    else
      @results = []
    end
    render 'evaluator'
  end
  
  def expert_workflow
    
  end
  
  private
  
  def get_index_names(variable)
    #temporary method to make sure the index names table is working by getting the index names from multiple sources
    variable_name_components = variable.name.split(/[\[\]]/)
    index_names_string = variable_name_components[1]
    index_names_from_table = variable.index_names().order("position").collect { |i| i.name }
    if index_names_string
      index_names = index_names_string.split(',')
    else
      index_names = nil
    end
    if !index_names.nil? && index_names_from_table[0].nil?
      raise "index names didn't work.  Variable had index names #{index_names_string}, but index names table had nothing."
    end
    if index_names_string.to_s != index_names_from_table.join(",")
      raise "index names didn't match.  Variable had index names #{index_names_string.inspect}, but index names table had #{index_names_from_table.join(",").inspect}."
    end
    if index_names_from_table.length == 0
      return nil
    end
    return index_names_from_table
  end
  
end
