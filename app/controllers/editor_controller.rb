class EditorController < ApplicationController
  def home
    # No changes
  end
  
  def variableeditor
    @new_var = Variable.new(params[:var])
    @new_var.save
    @variables = Variable.find(:all)
    render 'variableeditor'
  end
end
