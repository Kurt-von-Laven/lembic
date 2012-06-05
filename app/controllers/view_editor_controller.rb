class ViewEditorController < ApplicationController
  def edit_block
    
    # Create block to be used by form_for
    @block = Block.new
    
    ## Check for form data for creating new block
    form_hash = params[:create_block]
    if !form_hash.nil?

      #### BUG: this code for creating blocks doesn't work right now
      # Create a block with the specified name and workflow_id
      name = form_hash[:name]
      workflow_id = session[:user_id]
      sort_index = Block.where(:workflow_id => workflow_id).size
      Block.create({:name => name, :workflow_id => workflow_id, :sort_index => sort_index})
    end
    
    form_hash = params[:create_block_inputs]
    create_block_variables(form_hash, :input)
    
    form_hash = params[:create_block_outputs]
    create_block_variables(form_hash, :output)

    ## Check for form data for creating a block_connection
    form_hash = params[:create_block_connections]
    if !form_hash.nil?

      # Find the block these variables are for
      block_name = form_hash[:name]
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
        expression_string = tokens[0].strip # TODO: catch and handle parser errors
        next_block_name = tokens[1].strip
        
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
    
    ## Set variables used by views for rendering
    @variables = Variable.where(:model_id => session[:user_id]).order(:name)
    @blocks = Block.where(:workflow_id => session[:user_id]).order(:sort_index)

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
  
  # Check for form data for creating a block_variable
  def create_block_variables(form_hash, display_type)
    if !form_hash.nil?
      
      # Find the block these variables are for
      block_name = form_hash[:name]
      
      block = Block.find_by_name(block_name)
      if block.nil?
        flash[:block_failed] = "We couldn't find that block! Oops! Please try again."
        return
      end
      
      
      # Iterate through lines in the input string
      form_hash[:variables_string].lines do |line|
        
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
        bv = block.block_variables.create({:display_type => display_type, :variable_id => variable.id, :sort_index => sort_index})
        if bv.nil?
          flash[:block_failed] = "Failed to create block_variable with variable_id => #{variable.id} and sort_index => #{sort_index}"
        end
      end
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
