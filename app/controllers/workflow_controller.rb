require './app/helpers/expression'

class WorkflowController < ApplicationController
  
  def evaluate
       @variables = Variable.where(:workflow_id => session[:user_id]).order(:name)
    vars = params[:variables]
    if !vars.nil?
      input_values = eval(vars['input_values'])
      for input_variable, input_formula in input_values
        input_values[input_variable] = {:value => input_formula}
      end
      Variable.find(:all).each do |variable|
        expression_object = variable.expression_object
        input_values[variable.name] = {:formula => expression_object} unless expression_object.nil?
      end
      output_variable = vars['output_variable']
      evaluator = Evaluator.new
      evaluator.eval_variable(output_variable, input_values, nil)
      @results = input_values
    else
      @results = []
    end
    render 'evaluator'
  end
  
  def expert_workflow
    
  end
  
end
