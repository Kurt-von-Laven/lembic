class ViewEditorController < ApplicationController
  def edit_block
    
    # Create block to be used by form_for
    @block = Block.new
    
    ## Check for form data for creating new block
    form_hash = params[:create_block_form]
    if !form_hash.nil?

      #### BUG: this code for creating blocks doesn't work right now
      # Create a block with the specified name and workflow_id
      name = form_hash[:name]
      workflow_id = session[:user_id]
      display_type = nil # display_type is nil for regular input blocks
      sort_index = Block.where(:workflow_id => workflow_id).size
      Block.create({:name => name, :workflow_id => workflow_id, :display_type => display_type, :sort_index => sort_index})
    end

    ## Check for form data for creating a block_variable
    form_hash = params[:create_block_inputs_form]
    if !form_hash.nil?

      # Find the block these variables are for
      block_name = form_hash[:block_name]
        
        block = Block.find_by_name(block_name)
        if block.nil?
            flash[:block_failed] = "We couldn't find that block! Oops! Please try again."
        end
             

      # Iterate through lines in the input string
      form_hash[:inputs_string].lines do |line|

        # Trim the line to get a variable name
        variable_name = line.strip
        if variable_name.empty? # TODO: get better input validation
            flash[:block_failed] = 'Your variable name was empty. Please try again.'
          next
        end

        # Find the variable
        variable = Variable.find_by_name(variable_name)
        if variable.nil?
            flash[:block_failed] = "Sorry, we couldn't find that variable! Please try again"
          next
        end

        # Determine sort_index
        sort_index = block.block_variables.size
        
        # Create a block variable
        # NOTE: this may fail for various reasons (i.e. sort_index collision from race condition)
        bi = block.block_variables.create({:display_type => :input, :variable_id => variable.id, :sort_index => sort_index})
        if bi.nil?
            flash[:block_failed] = "Failed to create block_variable with variable_id => #{variable.id} and sort_index => #{sort_index}"
        end
      end
    end

    ## Check for form data for creating a block_connection
    form_hash = params[:create_block_connections_form]
    if !form_hash.nil?

      # Find the block these variables are for
      block_name = form_hash[:block_name]
        block = Block.find_by_name(block_name)
        if block.nil?
            flash[:block_failed] = "Sorry, we could not find that block. Please try again."
        end

      # Create parser for parsing expression strings
      parser = Parser.new

      # Iterate through lines in the connections string
      form_hash[:connections_string].lines do |line|

        # Parse the line into a block name and expression
        tokens = line.split("=>")
        if tokens.length != 2 # TODO: get better input validation
          next
        end
        next_block_name = tokens[0].strip
        expression_string = tokens[1].strip # TODO: catch and handle parser errors

        # Find the next block
        next_block = Block.find_by_name(next_block_name)
        if next_block.nil?
          flash[:block_failed] =  "Could not find next block '#{next_block_name}' by name"
          next
        end
        
        # Determine the sort_index
        sort_index = block.block_connections.size

        # Create a block connection with the specified next_block and expression
        block_connection_hash = {:next_block_id => next_block.id, :expression_string => expression_string, :sort_index => sort_index}
        bc = block.block_connections.create(block_connection_hash)
        if bc.nil?
          flash[:block_failed] = "Failed to create block_connection from hash => #{block_connection_hash}"
        end
      end
    end

    ## Check for form data for creating an output block
    # Currently, "output" blocks are stored as the same type of
    # object, and do not have any associated block_connections
    # (this is how we know it is an output or terminal block).
    # The variables associated with this block will have
    # their computed values displayed in the format specified by
    # display_type, instead of displaying form prompts for input.

    # Note that with output blocks, the block name and block variables
    # are specified together in the same form, instead of independently
    # like with regular blocks.

    form_hash = params[:create_output_block_form]
    if !form_hash.nil?

      # Create a block with the specified name, workflow_id, and formatting
      name = form_hash[:name]
      workflow_id = session[:user_id]
      sort_index = Block.where(:workflow_id => workflow_id).size
      block = Block.create({:name => name, :workflow_id => workflow_id, :sort_index => sort_index})

      # Iterate through lines in the outputs string
      form_hash[:outputs_string].lines do |line|

        # Trim the line to get a variable name
        variable_name = line.strip
        if variable_name.empty? # TODO: get better input validation
          flash[:block_failed] =  "Empty line in input"
          next
        end

        # Find the variable
        variable = Variable.find_by_name(variable_name)
        if variable.nil?
          flash[:block_failed] =  "Could not find variable '#{variable_name}' by name"
          next
        end

        # Determine sort_index
        sort_index = block.block_variables.size

        # Create a block variable
        bi = block.block_variables.create({:variable_id => variable.id, :sort_index => sort_index})
        if bi.nil?
          flash[:block_failed] =  "Failed to create block_variable with variable_id => #{variable.id} and sort_index => #{sort_index}"
        end
      end
    end
    
    ## Check for form data for showing a block
    form_hash = params[:show_block_form]
    if !form_hash.nil?
      id = form_hash[:id]
      
      # Redirect to the show block page. I know, this is kind of hacky.
      redirect_to block_show_path(id)
    end



    ## Set variables used by views for rendering
    @variables = Variable.where(:model_id => session[:user_id]).order(:name)
    @blocks = Block.where(:workflow_id => session[:user_id]).order(:sort_index)

  end
  
  def edit_workflows
    form_hash = params[:workflow]
    @workflow = Workflow.new(form_hash)
    if form_hash
      @workflow.save
    end
    @current_workflows = Workflow.find_all_by_()
  end

  def edit_question
      @variables = Variable.where(:model_id => session[:user_id]).order(:name)
  end
    
    def find_blocknames
        @blocknames = Block.where('(workflow_id = ?) AND (name LIKE ?)', session[:user_id], "#{params[:term]}%").order(:name)
        respond_to do |format|
            format.js { render :layout => false }
        end
    end
  
  # Delete a block by id
  def delete_block
    #begin
      block = Block.find(params[:id])
      block.destroy
    #rescue RecordNotFound => e
    #  logger.debug "Block not found by id"
    #end
    redirect_to :back
  end
  
end
