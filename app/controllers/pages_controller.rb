class PagesController < ApplicationController
  def home	
	@variables = Variable.find(:all)
  end
end
