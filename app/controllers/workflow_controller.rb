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
        input_values_hash[@input_variables[i].name] = {:value => input_value}
        i += 1
      end
      Variable.find(:all).each do |variable|
        expression_object = variable.expression_object
        variable_name_components = variable.name.split(/[\[\]]/)
        index_names_string = variable_name_components[1]
        if index_names_string
          index_names = index_names_string.split(',')
          varname = variable_name_components[0]
        else
          index_names = nil
          varname = variable.name
        end
        input_values_hash[varname] ||= {}
        input_values_hash[varname][:formula] = expression_object unless expression_object.nil?
        input_values_hash[varname][:index_names] = index_names if index_names
      end
      evaluator = Evaluator.new
      evaluator.eval_all([], input_values_hash) # array of hashes mapping :name => variable_name, {:begin}
      @output_variables = input_values_hash
      logger.debug(input_values_hash.inspect)
    else
      @output_variables = []
    end
    render 'evaluator'
  end
  
  def expert_workflow
    
  end
  
end
