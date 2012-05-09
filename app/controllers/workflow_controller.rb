class WorkflowController < ApplicationController
  
  def evaluate
    if !params.nil? and !(params[:variables].nil?)
      variables = params[:variables]
      puts variables.inspect
      input_values = eval(variables['input_values'])
      for input_variable, input_formula in input_values
        input_values[input_variable] = {:value => input_formula}
      end
      Variable.find(:all).each do |variable|
        expression_object = variable.expression_object
        input_values[variable.name] = {:formula => expression_object} unless expression_object.nil?
      end
      puts input_values.inspect
      output_variable = variables['output_variable']
      evaluator = Evaluator.new
      evaluator.eval_variable(output_variable, input_values, nil)
      @results = input_values
    else
      @results = []
    end
    render 'evaluator'
  end
  
end
