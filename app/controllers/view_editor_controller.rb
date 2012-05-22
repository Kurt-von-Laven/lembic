class ViewEditorController < ApplicationController

  def editblock
      # Check for form data for creating new block
      form_hash = params[:create_block_form]
      if !form_hash.nil?
        
        # Create a block with the specified name
        block_hash = {:name => form_hash[:name]}
        block = Block.create(block_hash)
        
        # Iterate through lines in the connections string
        connection_lines = []
        form_hash[:connections_string].lines do |line|

          # Parse the line into a block name and expression
          tokens = line.split("=>")
          if !(tokens.length == 2) # TODO: get better input validation
            next
          end
          next_block = tokens[0].strip
          expression = tokens[1].strip
          
          # Create a block connection with the specified next_block and expression
          block_connection_hash = {:next_block => next_block, :expression => expression}
          block.block_connections.create(block_connection_hash)
        end
      end
      
      # Set variables used by views for rendering
      @variables = Variable.where(:workflow_id => session[:user_id]).order(:name)
      @blocks = Block.find(:all)
      
  end

  def editquestion
      @variables = Variable.where(:workflow_id => session[:user_id]).order(:name)
  end
  
end
