class PagesController < ApplicationController
  def home	
	@variables = Variable.find(:all)
	@var = Variable.new(params[:var])
      @var.save
	render 'home'
  end
end
