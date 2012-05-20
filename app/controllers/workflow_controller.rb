require 'yaml'
require './app/helpers/expression'

class WorkflowController < ApplicationController
  
  def evaluate
    if !params.nil? and !(params[:variables].nil?)
      variables = params[:variables]
      input_values = eval(variables['input_values'])
      for input_variable, input_formula in input_values
        input_values[input_variable] = {:value => input_formula}
      end
      Variable.find(:all).each do |variable|
        expression_object = variable.expression_object
        input_values[variable.name] = {:formula => YAML::load(expression_object)} unless expression_object.nil?
      end
      output_variable = variables['output_variable']
      evaluator = Evaluator.new
      puts output_variable.inspect
      puts input_values.inspect
      evaluator.eval_variable(output_variable, input_values, nil)
      @results = input_values
    else
      @results = []
    end
    render 'evaluator'
  end
  
end
