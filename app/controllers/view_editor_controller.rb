class ViewEditorController < ApplicationController

  def editblock
      @variables = Variable.where(:workflow_id => session[:user_id]).order(:name)
  end

  def editquestion
      @variables = Variable.where(:workflow_id => session[:user_id]).order(:name)
  end
end
