class ViewEditorController < ApplicationController

  def editblock
      @variables = Variable.order(:name)
  end

  def editquestion
      @variables = Variable.order(:name)
  end
end
