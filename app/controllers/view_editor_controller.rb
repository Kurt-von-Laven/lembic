class ViewEditorController < ApplicationController

  def edit_block
      # Check for form data for creating new block
      form_hash = params[:create_block_form]
      if !form_hash.nil?
        
        # Create a block with the specified name and workflow_id
        name = form_hash[:name]
        workflow_id = session[:user_id]
        block = Block.create({:name => name, :workflow_id => workflow_id})
      end
      
      # Check for form data for creating a block_input
      form_hash = params[:create_block_inputs_form]
      if !form_hash.nil?
        
        # Find the block these inputs are for
        block_name = form_hash[:block_name]
        block = Block.find_by_name(block_name)
        # TODO: check for error finding block
        
        # Iterate through lines in the inputs string
        form_hash[:inputs_string].lines do |line|
          
          # Trim the line to get a variable name
          variable_name = line.strip
          if variable_name.empty? # TODO: get better input validation
            next
          end
          
          # Determine sort_index
          sort_index = 0
          
          # Create a block input with the specified variable
          block.block_inputs.create({:variable => variable_name, :sort_index => sort_index})
        end
      end
      
      # Check for form data for creating a block_connection
      form_hash = params[:create_block_connections_form]
      if !form_hash.nil?
        
        # Find the block these inputs are for
        block_name = form_hash[:block_name]
        block = Block.find_by_name(block_name)
        # TODO: check for error finding block
        
        # Create parser for parsing expression strings
        parser = Parser.new
        
        # Iterate through lines in the connections string
        form_hash[:connections_string].lines do |line|

          # Parse the line into a block name and expression
          tokens = line.split("=>")
          if tokens.length != 2 # TODO: get better input validation
            next
          end
          next_block = tokens[0].strip
          expression_string = tokens[1].strip
          
          # Parse the expression into an object, using parser
          expression_object = parser.parse(expression_string) # TODO: Catch and handle parser errors.
          
          # Determine the sort_index
          sort_index = 0
          
          # Create a block connection with the specified next_block and expression
          block_connection_hash = {:next_block => next_block, :expression_string => expression_string, :expression_object => expression_object, :sort_index => sort_index}
          block.block_connections.create(block_connection_hash)
        end
      end
      
      # Set variables used by views for rendering
      @variables = Variable.where(:workflow_id => session[:user_id]).order(:name)
      @blocks = Block.where(:workflow_id => session[:user_id]).order(:name)
      
  end

  def edit_question
      @variables = Variable.where(:workflow_id => session[:user_id]).order(:name)
  end
  
end
