class BlockController < ApplicationController
  
  # Display a block so that user can enter data into it
  def show
    
    # Get the id param
    id = params[:id]
    
    # Locate the block specified by id
    @block = Block.find(id)
    
  end
  
  # Record data entered into this block, redirect to the appropriate next block
  def input
    
    # Get block_id and hash of input values
    form_hash = params[:block_inputs]
    block_id = form_hash[:block_id]
    inputs_hash = form_hash[:inputs]
    
    # Record the input values
    
    # Determine which block_connection to follow
    block = Block.find(block_id)
    for bc in block.block_connections.order(:sort_index)
      
      block_name = bc.next_block.name
      str = bc.expression_string
      logger.debug "++++++++++++Testing block_connection to #{block_name}: #{str}"
      
      # Get expression object
      
      # Test boolean expression
      if false
        
        # Redirect to next block
        next_block_id = bc.next_block.id
        redirect_to block_show_path(next_block_id)
      end
    end
    
    # Redirect to default block (output)
    # TODO: select the correct default block
    redirect_to block_show_path(1)
    
  end
  
end
