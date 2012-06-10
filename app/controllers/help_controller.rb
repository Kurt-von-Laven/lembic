class HelpController < ApplicationController
  
  skip_before_filter :verify_model, :verify_workflow
  
  def help
  end
end
