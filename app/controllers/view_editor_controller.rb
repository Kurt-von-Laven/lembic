class ViewEditorController < ApplicationController

  def editblock
      @variables = Variable.where(:workflow_id => session[:user_id]).order(:name)
      
      # Check for form data for creating new block
      form_hash = params[:new_block]
      if !form_hash.nil?
        # Create new block from the form data
        Block.create(form_hash)
      end
  end

  def editquestion
      @variables = Variable.where(:workflow_id => session[:user_id]).order(:name)
  end
  
end
