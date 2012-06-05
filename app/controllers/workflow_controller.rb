require Rails.root.join('app/helpers/expression')
require Rails.root.join('app/helpers/evaluator')
require Rails.root.join('app/helpers/parser')

class WorkflowController < ApplicationController
  
  def evaluate
    @variables = Variable.where(:model_id => session[:user_id]).order(:name)
    @input_variables = Variable.where(:model_id => session[:user_id], :expression_string => nil).order(:name)
    vars = params[:evaluator]
    if !vars.nil?
      input_values = (vars['input_values'].nil?) ? [] : vars['input_values']
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
        index_names = variable.index_name_strings
        input_values_hash[varname] ||= {}
        input_values_hash[varname][:formula] = expression_object unless expression_object.nil? # This unless just saves some space in the Hash.
        input_values_hash[varname][:index_names] = index_names unless index_names.nil? # This unless just saves some space in the Hash.
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
        for variable_name, variable_properties in input_values_hash
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
  
  def run
    #get blocks for this workflow
    #find first block in workflow
    #
  end
  
  def expert_workflow
    
  end
  
  ##
  # creates a new run object for the workflow id specified in params[:id]
  # sets the run's current block to the start block of the workflow
  # redirects to show the first block
  def start_run
    workflow = Workflow.where(:id => params[:id]).first
    start_block = Block.where(:id => workflow.workflow_blocks().where(:sort_index => 0).block_id).first
    new_run = Run.create({:user_id => session[:user_id],
                          :workflow_id => workflow.id,
                          :current_block_id => start_block.id
                        })
    redirect_to :action => 'block', :id => start_block.id, :run_id => new_run.id
  end
  
  ##
  # params[:id] is the id of the block being submitted
  # get the run id from a hidden field
  # store the user-entered values in run_values
  # build a hash of variable names to values and formulas to be run through the evaluator
  # display the next block based on transition logic
  def block
    curr_block = Block.where(:id => params[:id]).first
    @run = Run.where(:id => params[:run_id]).first
    for var_id, val in params[:input_values] do
      RunValue.create({:run_id => @run.id, :variable_id => var_id, :value => val})
    end
    workflow = run.workflow
    model = workflow.model
    block_connections = curr_block.block_connections()
    run_values = run.run_values
    @variables_hash = variables_hash_for_run(run)
    
    # figure out which block to display next
    connections = curr_block.block_connections
    next_block = nil
    for b in connections
      if evaluator.eval_expression(b.expression_object, variables_hash, nil) != 0
        # expression evaluates to true
        next_block = Block.where(:id => b.block_id).first
        break
      end
    end
    if next_block
      @block = next_block
      @block_variables = next_block.block_variables().order(:sort_index)
      render 'block'
    end
    # TODO: Show an error if next_block is nil.
  end
  
  def create_workflow
    Workflow.create(params[:workflow])
    # TODO: give current user permissions for this workflow in WorkflowPermissions table
  end
  
  def add_block_to_workflow
    WorkflowBlock.create(params[:workflow_block])
  end
  
  def connect_blocks
    connection_hash = params[:block_connection]
    connection_hash[:expression_object] = Parser.new.parse(connection_hash[:expression_string])
    BlockConnections.create(connection_hash)
  end
  
  private
  
  def to_i_safely(str)
    return nil unless str.instance_of?(String)
    return 0 if str == '0'
    str_as_integer = str.to_i
    return (str_as_integer == 0) ? nil : str_as_integer
  end
  
  def variables_hash_for_run(run)
    run_values = run.run_values
    variables_hash = {} #stores formulas and values to be passed to the evaluator
    for v in model.variables do
      variables_hash[v.name] = {:formula => v.expression_object}
      variables_hash[v.name][:index_names] = v.index_names.order(:sort_index).collect{|i| i.name}
    end
    for v in run_values do
      varname = v.variable.name
      value = v.value
      variables_hash[varname] = {:value => value}
    end
    return variables_hash
  end

  
end
