require Rails.root.join('app/helpers/expression')
require Rails.root.join('app/helpers/evaluator')
require Rails.root.join('app/helpers/parser')


class WorkflowController < ApplicationController
  def evaluate
    @variables = Variable.where(:model_id => session[:model_id]).order(:name)
    @input_variables = Variable.where(:model_id => session[:model_id], :expression_string => nil).order(:name)
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
      Variable.all.each do |variable|
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
  
  # params[:id] is the id of the block being submitted
  # get the run id from a hidden field
  # store the user-entered values in run_values
  # build a hash of variable names to values and formulas to be run through the evaluator
  # display the next block based on transition logic
  def expert_workflow
    curr_block = Block.where(:id => params[:input_values][:id]).first
    run_id = params[:run_id] 
    run_id = params[:input_values]["run_id"] if run_id.nil?
    @run = Run.where(:id => run_id).first
    input_values = params[:input_values]
    if !input_values.nil?
      for var_id, val in input_values do
        next if var_id == "run_id" || var_id == "id" #THIS IS SO GROSS EWWWW EW EW EW
        RunValue.create({:run_id => @run.id, :variable_id => var_id, :value => val})
      end
    end
    @variables_hash = variables_hash_for_run(@run)
    
    if params[:first_block]
      @block = curr_block
      @block_variables = @block.block_variables().order(:sort_index)
      render 'expert_workflow'
      return
    end
    
    # figure out which block to display next
    block_connections = curr_block.block_connections.order(:sort_index)
    next_block = nil
    @evaluator = Evaluator.new
    for b in block_connections
      if @evaluator.eval_expression(b.expression_object, @variables_hash, nil) != 0
        # expression evaluates to true
        next_block = Block.where(:id => b.next_block_id).first
        break
      end
    end
    if !next_block.nil?
      @block = next_block
      @block_variables = next_block.block_variables().order(:sort_index)
      render 'expert_workflow'
    else
      #next block is nil, so workflow is done
      redirect_to '/view_editor/edit_block'
    end
    # TODO: Show an error if next_block is nil.
  end
  
  ##
  # creates a new run object for the workflow id specified in params[:id]
  # sets the run's current block to the start block of the workflow
  # redirects to show the first block
  def start_run
    start_block = Block.where('workflow_id = ? and sort_index = 0', workflow.id).first
    new_run = Run.create({:user_id => session[:user_id],
                          :workflow_id => workflow.id,
                          :block_id => start_block.id
                        })
    redirect_to :action => 'expert_workflow', :input_values => {:id => start_block.id, :run_id => new_run.id}, :first_block => true # TODO: This should be a POST request, but all redirects are GET requests.
  end
    
  def create_workflow
    save_successful = false
    ActiveRecord::Base.transaction do
      new_workflow = Workflow.new(params[:workflow])
      save_successful = new_workflow.save
      permission = WorkflowPermission.new(:user_id => session[:user_id], :workflow_id => new_workflow.id, :permissions => 0)
      save_successful &&= permission.save
    end
    if save_successful
      flash[:workflow_created] = 'Workflow successfully created.'
    else
      flash[:workflow_creation_failed] = new_workflow.errors.full_messages.join(' ')
    end
  end
  
  def add_block_to_workflow
    WorkflowBlock.create(params[:workflow_block])
  end
  
  private
  
  def to_i_safely(str)
    return nil unless str.instance_of?(String)
    return 0 if str == '0'
    str_as_integer = str.to_i
    return (str_as_integer == 0) ? nil : str_as_integer
  end
  
  def variables_hash_for_run(run)
    workflow = run.workflow
    model = Model.find(session[:model_id])
    run_values = run.run_values
    variables_hash = {} #stores formulas and values to be passed to the evaluator
    for v in model.variables do
      variables_hash[v.name] = {:formula => v.expression_object}
      variables_hash[v.name][:index_names] = v.index_names.order(:sort_index).collect{|i| i.name}
    end
    for v in run_values do
      varname = v.variable.name
      value = v.value
      variables_hash[varname] = {:value => value.to_f}
    end
    return variables_hash
  end
  
  def set_current
    workflow_hash = params[:workflow]
    if !workflow_hash.nil?
      new_workflow_id = workflow_hash[:id]
      new_workflow_permission = WorkflowPermission.where(:user_id => session[:user_id], :workflow_id => new_workflow_id).first
      if new_workflow_permission.nil?
        flash[:invalid_workflow_id] = 'You tried to select a workflow that either doesn\'t exist or that you don\'t have permission to use.'
      else
        session[:workflow_id] = new_workflow_id
      end
    end
    redirect_to :back
  end
  
end
