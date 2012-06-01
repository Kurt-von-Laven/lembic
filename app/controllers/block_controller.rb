class BlockController < ApplicationController
  
  # Display a block so that user can enter data into it
  def show
    
    # Get the id param
    id = params[:id]
    
    # Locate the block specified by id
    @block = Block.find(id)
    
  end
  
end
