class BlockController < ApplicationController
  
  # Display a block so that user can enter data into it
  def show
    
    # Get the id param
    id = params[:id]
    
    # Locate the block specified by id
    @block = Block.find(id)
    
  end
  
  # Record data entered into this block, redirect to the appropriate next block
  # This should happen when the user clicks SUBMIT after entering variables in a block
  def variables
    
    # Get block_id and hash of variable values
    form_hash = params[:block_variables]
    block_id = form_hash[:block_id]
    variables_hash = form_hash[:variables]
    
    # Record the variable values
    variables_hash.each do |variable_id, value|
      
      logger.debug "+++++++++++++Received value for variable_id #{variable_id}: #{value}"
      
      # Record the value for the variable specified by variable_id
      # TODO: make a call to the right class for doing this
      
      
    end
    
    # Determine which block_connection to follow
    block = Block.find(block_id)
    for bc in block.block_connections.order(:sort_index)
      
      block_name = bc.next_block.name
      str = bc.expression_string
      logger.debug "++++++++++++Testing block_connection to block #{block_name}: #{str}"
      
      # Test boolean expression object
      expression = bc.expression_object
      expression_value = false #TODO: replace with a call to the Evaluator
      
      # If true, follow that connection
      if expression_value == true
        
        # Redirect to next block
        next_block_id = bc.next_block.id
        redirect_to block_show_path(next_block_id)
      end
    end
    
    # Default: Redirect to the first output block
    block = Block.where("display_type IS NOT NULL").first
    redirect_to block_show_path(block.id)
    
  end
  
end
