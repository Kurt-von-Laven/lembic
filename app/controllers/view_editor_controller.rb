class ViewEditorController < ApplicationController
  
  skip_before_filter :verify_workflow, :only => [:edit_block, :create_workflow]
  
  def edit_block
    ActiveRecord::Base.transaction do
    ## Set variables used by views for rendering
      @variables = Variable.where(:model_id => session[:model_id]).order(:name)
      @blocks = Block.where(:workflow_id => session[:workflow_id]).order(:sort_index)
      
      # Create block to be used by form_for
      @block = Block.new
      
      # Get data from the session
      workflow_id = session[:workflow_id]
      
      ## Check for form data for creating new block
      form_hash = params[:create_block]
      if !form_hash.nil?
        # Create a block with the specified name and workflow_id
        name = form_hash[:name]
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
          #create the block if it doesn't already exist
          
          from_block = Block.create({:name => from_block_name, :workflow_id => workflow_id, :sort_index => Block.where(:workflow_id => workflow_id).size})
          #flash[:block_failed] = "Could not find block named #{from_block_name}."
          #return
        end
        
        to_block_name = form_hash[:to_name]
        to_block = Block.find_by_name(to_block_name)
        if to_block.nil?
          to_block = Block.create({:name => to_block_name, :workflow_id => workflow_id, :sort_index => Block.where(:workflow_id => workflow_id).size})
          #flash[:block_failed] = "Could not find block named #{to_block_name}."
          #return
        end
        
        #parser = Parser.new
        
        expression_string = form_hash[:expression_string]
        
        # Determine the sort_index
        sort_index = from_block.block_connections.size

        # Create a block connection with the specified next_block and expression
        block_connection_hash = {:next_block_id => to_block.id, :expression_string => expression_string, :sort_index => sort_index}
        bc = from_block.block_connections.create(block_connection_hash)
        if bc.nil?
          flash[:block_failed] = "Failed to create block_connection from hash => #{block_connection_hash.inspect}"
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
    ActiveRecord::Base.transaction do
      if !form_hash.nil?
        
        # Find the block these variables are for
        block_name = form_hash[:name]
        
        workflow_id = session[:workflow_id]
        
        block = Block.find_by_name(block_name)
        if block.nil?
          block = Block.create({:name => block_name, :workflow_id => workflow_id, :sort_index => Block.where(:workflow_id => workflow_id).size})
        end
        
        
        # Iterate through lines in the input string
        form_hash[:variables_string].lines do |line|
          
          # Trim the line to get a variable name
          variable_name = line.strip
          if variable_name.empty? # TODO: get better input validation
            flash.now[:block_failed] = 'Your variable name was empty. Please try again.'
            next
          end
          
          # Find the variable
          variable = Variable.find_by_name(variable_name)
          if variable.nil?
            flash.now[:block_failed] = "Sorry, we couldn't find a variable named #{variable_name}! Please try again"
            next
          end
          
          # Determine sort_index
          sort_index = block.block_variables.size
          
          # Create a block variable
          # NOTE: this may fail for various reasons (i.e. sort_index collision from race condition)
          bv = block.block_variables.create({:display_type => display_type, :variable_id => variable.id, :sort_index => sort_index})
          if bv.nil?
            flash.now[:block_failed] = "Failed to create block_variable with variable_id => #{variable.id} and sort_index => #{sort_index}"
          end #end if
        end #end form
      end # end if
    end # end transaction
  end # end create_block_variables
  
  def create_workflow
    workflow_hash = params[:create_workflow]
    if !workflow_hash.nil?
      name = workflow_hash[:name]
      description = workflow_hash[:description]
      new_workflow = Workflow.new(:name => name, :description => description, :model_id => session[:model_id])
      save_successful = false
      ActiveRecord::Base.transaction do
        new_workflow.sort_index = Model.find(session[:model_id]).workflows.length
        save_successful = new_workflow.save!
        permission = WorkflowPermission.new(:user_id => session[:user_id], :workflow_id => new_workflow.id, :permissions => 0)
        save_successful &&= permission.save!
      end
      if save_successful
        session[:workflow_id] = new_workflow.id
        flash[:workflow_created] = 'Workflow successfully created.'
      else
        flash[:workflow_creation_failed] = new_workflow.errors.full_messages.join(' ')
      end
    end
    redirect_to :back
  end
  
  # Delete a block by id
  def delete_block
    Block.destroy(params[:id])
    render :text => "Block with ID #{params[:id]} was successfully destroyed."
  end
  
  def delete_block_connection
    BlockConnection.destroy(params[:id])
    redirect_to :back
  end
  
  def delete_block_variable
    BlockVariable.destroy(params[:id])
    redirect_to :back
  end
  
  #params[:id] is the id of the block to move
  #params[:sort_index] is the new sort index for the block.  The other blocks are moved to accomodate the new position of the block.
  def reorder_block
    Block.transaction do
      moved_block = Block.find(params[:id])
      old_sort_index = moved_block.sort_index
      new_sort_index = params[:sort_index]
      
      #shift the sort_indices of the blocks between the old and new sort_index up or down
      
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
      block.save!
    end
    
  end
  
end
