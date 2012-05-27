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
        variable_name_components = variable.name.split(/[\[\]]/)
        index_names_string = variable_name_components[1]
        if index_names_string
          index_names = index_names_string.split(",")
          varname = variable_name_components[0]
        else
          index_names = nil
          varname = variable.name
        end
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
  
end
