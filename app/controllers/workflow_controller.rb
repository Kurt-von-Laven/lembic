require Rails.root.join('app/helpers/expression')
require Rails.root.join('app/helpers/evaluator')
require Rails.root.join('app/helpers/parser')
require 'csv_importer'


class WorkflowController < ApplicationController
  def evaluate
    Variable.transaction do
      @variables = Variable.where(:model_id => session[:model_id]).order(:name)
      @input_variables = Variable.where(:model_id => session[:model_id], :expression_string => nil).order(:name)
      vars = params[:evaluator]
      if !vars.nil?
        input_values = (vars['input_values'].nil?) ? [] : vars['input_values']
        input_values_hash = {}
        i = 0
        
        # put input values into a hash to be passed to the evaluator
        for input_value in input_values
          if !input_value.instance_of?(String)
            # variable is an array
            input_array = CsvImporter.parse_csv_to_array(input_value[:data_file].read, CsvImporter.convert_letter_column_labels_to_numbers(input_value[:start_row]), input_value[:start_col].to_i, @input_variables[i].variable_type)
            input_array_values_hash = {}
            input_array.each_with_index do |value, i|
              input_array_values_hash[[i + 1.0]] = value
            end
            input_values_hash[@input_variables[i].name] = {:values => input_array_values_hash}
          else
            # variable is a scalar
            input_value_as_integer = to_i_safely(input_value)
            input_value = (input_value_as_integer.nil?) ? input_value : input_value_as_integer
            input_values_hash[@input_variables[i].name] = {:value => input_value}
          end
          i += 1
        end
        
        variable_to_solve_for = Variable.where(:name => vars['variable_to_solve_for'], :model_id => session[:model_id]).first
        Variable.where(:model_id => session[:model_id]).each do |variable|
          expression_object = variable.expression_object
          varname = variable.name.split(/\s*\[/)[0]
          index_names = variable.index_name_strings
          input_values_hash[varname] ||= {}
          input_values_hash[varname][:formula] = expression_object unless expression_object.nil? # This unless just saves some space in the Hash.
          input_values_hash[varname][:index_names] = index_names unless index_names.nil? # This unless just saves some space in the Hash.
        end
        if variable_to_solve_for.nil?
          if vars['variable_to_solve_for'].nil?
            flash.now[:evaluator_error] = 'Variable to solve for can\'t be blank.' # TODO: Check for this case at the beginning of the function.
          else
            flash.now[:evaluator_error] = "You tried to solve for the variable #{vars['variable_to_solve_for']}, but that variable doesn't exist."
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
        # vars is nil
        @output_variables = []
      end
    end
    render 'evaluator'
  end
  
  # params[:id] is the id of the block being submitted
  # get the run id from a hidden field
  # store the user-entered values in run_values
  # build a hash of variable names to values and formulas to be run through the evaluator
  # display the next block based on transition logic
  def expert_workflow
    ActiveRecord::Base.transaction do
      curr_block = Block.where(:id => params[:block_id]).first
      if !curr_block
        raise "Couldn't find block with id #{params[:block_id]}"
      end
      run_id = params[:run_id]
      @run = Run.where(:id => run_id).first
      input_values = params[:input_values]
      if !input_values.nil?
        for block_var_id, block_var_params in input_values do
          #next if block_var_id == "run_id" || block_var_id == "id" #THIS IS SO GROSS EWWWW EW EW EW
          variable_id = block_var_params[:variable_id]
          if block_var_params[:data_file]
            #variable is an array
            csv_data = block_var_params[:data_file].read
            start_row = CsvImporter.convert_letter_column_labels_to_numbers(block_var_params[:start_row])
            start_col = CsvImporter.convert_letter_column_labels_to_numbers(block_var_params[:start_col])
            variable = Variable.find(variable_id)
            index_names = variable.index_names
            if index_names.length != 1
              raise "Uploading of multidimensional arrays is not yet supported."
            end
            array_data = CsvImporter.parse_csv_to_array(csv_data, start_row, start_col, variable.variable_type)
            index = 1
            for elem in array_data
              RunValue.create({:run_id => @run.id, :variable_id => variable_id, :index_values => [index], :value => elem})
              index += 1
            end
          else
            #variable is a scalar
            value = block_var_params[:value]
            RunValue.create({:run_id => @run.id, :variable_id => variable_id, :value => value})
          end
        end
      end
      @variables_hash = variables_hash_for_run(@run)
      
      @evaluator = Evaluator.new
      
      if params[:first_block]
        @block = curr_block
        @block_variables = @block.block_variables().order(:sort_index)
        render 'expert_workflow'
        return
      end
      
      # figure out which block to display next
      block_connections = curr_block.block_connections.order(:sort_index)
      next_block = nil
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
    end
    # TODO: Show an error if next_block is nil.
  end
  
  ##
  # creates a new run object for the workflow id specified in params[:id]
  # sets the run's current block to the start block of the workflow
  # redirects to show the first block
  def start_run
    workflow_id = params[:id]
    start_block = Block.new
    ActiveRecord::Base.transaction do
      start_block = Block.where('workflow_id = ? and sort_index = 0', workflow_id).first
      new_run = Run.create({:user_id => session[:user_id],
                             :workflow_id => workflow_id,
                             :block_id => start_block.id
                           })
    end
    redirect_to :action => 'expert_workflow', :block_id => start_block.id, :run_id => new_run.id, :first_block => true # TODO: This should be a POST request, but all redirects are GET requests.
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
    ActiveRecord::Base.transaction do
      workflow = run.workflow
      model = Model.find(session[:model_id])
      run_values = run.run_values
    end
    variables_hash = {} #stores formulas and values to be passed to the evaluator
    for v in model.variables do
      variables_hash[v.name] = {:formula => v.expression_object}
      variables_hash[v.name][:index_names] = v.index_names.order(:sort_index).collect{|i| i.name}
    end
    for v in run_values do
      varname = v.variable.name
      value = v.value
      if v.index_values
        #variable is an array
        variables_hash[varname][:values] ||= {}
        variables_hash[varname][:values][v.index_values.collect{|i| i.to_f}] = value.to_f
      else
        #variable is a scalar
        variables_hash[varname] = {:value => value.to_f}
      end
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
