class ViewEditorController < ApplicationController
  def edit_block
    ActiveRecord::Base.transaction do
    ## Set variables used by views for rendering
      @variables = Variable.where(:model_id => session[:model_id]).order(:name)
      @blocks = Block.where(:workflow_id => session[:workflow_id]).order(:sort_index)
      
      # Create block to be used by form_for
      @block = Block.new
      
      ## Check for form data for creating new block
      form_hash = params[:create_block]
      if !form_hash.nil?
        # Create a block with the specified name and workflow_id
        name = form_hash[:name]
        workflow_id = session[:workflow_id]
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
        
        from_block_name = form_hash[:from_name]
        from_block = Block.find_by_name(from_block_name)
        if from_block.nil?
          flash[:block_failed] = "Could not find block named #{from_block_name}."
          return
        end
        
        to_block_name = form_hash[:to_name]
        to_block = Block.find_by_name(to_block_name)
        if to_block.nil?
          flash[:block_failed] = "Could not find block named #{to_block_name}."
          return
        end
        
        #parser = Parser.new
        
        expression_string = form_hash[:expression_string]
        
        # Determine the sort_index
        sort_index = from_block.block_connections.size

        # Create a block connection with the specified next_block and expression
        block_connection_hash = {:next_block_id => to_block.id, :expression_string => expression_string, :sort_index => sort_index}
        bc = from_block.block_connections.create(block_connection_hash)
        if bc.nil?
          flash[:block_failed] = "Failed to create block_connection from hash => #{block_connection_hash}"
        end
      end
    end
    
  end # edit_block
  
  def edit_question
    @variables = Variable.where(:model_id => session[:model_id]).order(:name)
  end
  
  def find_block_names
    @block_names = Block.where('(workflow_id = ?) AND (name LIKE ?)', session[:workflow_id], "#{params[:term]}%").order(:name)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end #find_block_names
  
  # Check for form data for creating a block_variable
  def create_block_variables(form_hash, display_type)
    if !form_hash.nil?
      
      # Find the block these variables are for
      block_name = form_hash[:name]
      
      block = Block.find_by_name(block_name)
      if block.nil?
        flash[:block_failed] = "We couldn't find that block! Oops! Please try again."
        return
      end #end if
      
      
      # Iterate through lines in the input string
      form_hash[:variables_string].lines do |line|
        
        # Trim the line to get a variable name
        variable_name = line.strip
        if variable_name.empty? # TODO: get better input validation
          flash[:block_failed] = 'Your variable name was empty. Please try again.'
          next
        end #end if
        
        # Find the variable
        variable = Variable.find_by_name(variable_name)
        if variable.nil?
          flash[:block_failed] = "Sorry, we couldn't find that variable! Please try again"
          next
        end # end if
        
        # Determine sort_index
        sort_index = block.block_variables.size
        
        # Create a block variable
        # NOTE: this may fail for various reasons (i.e. sort_index collision from race condition)
        bv = block.block_variables.create({:display_type => display_type, :variable_id => variable.id, :sort_index => sort_index})
        if bv.nil?
          flash[:block_failed] = "Failed to create block_variable with variable_id => #{variable.id} and sort_index => #{sort_index}"
        end #end if
      end #end form
    end # end if
  end # end create_block_variables
    
  # Delete a block by id
  def delete_block
    block = Block.find(params[:id])
    block.destroy
    render :text => "Block with ID #{params[:id]} was successfully destroyed."
  end
  
  def delete_block_connection
    block_connection = BlockConnection.find(params[:id])
    block_connection.destroy
    redirect_to :back
  end
  
  def delete_block_variable
    block_variable = BlockVariable.find(params[:id])
    block_variable.destroy
    redirect_to :back
  end
  
  #params[:id] is the id of the block to move
  #params[:sort_index] is the new sort index for the block.  The other blocks are moved to accomodate the new position of the block.
  def reorder_block
    moved_block = Block.find(params[:id])
    old_sort_index = moved_block.sort_index
    new_sort_index = params[:sort_index]
    
    #shift the sort_indices of the blocks between the old and new sort_index up or down
    Block.transaction do
      if new_sort_index < old_sort_index
        blocks_to_shift = Block.where("sort_index < ? and sort_index >= ? and workflow_id = ? ", old_sort_index, new_sort_index, block.workflow_id)
        blocks_to_shift.each do |b|
          b.sort_index += 1
          b.save :validate => false
        end
      elsif new_sort_index > old_sort_index
        blocks_to_shift = Block.where("sort_index =< ? and sort_index > ? and workflow_id = ? ", new_sort_index, old_sort_index, block.workflow_id)
        blocks_to_shift.each do |b|
          b.sort_index -= 1
          b.save :validate => false
        end
      end
      block.sort_index = new_sort_index
      block.save
    end
    
  end
  
end
