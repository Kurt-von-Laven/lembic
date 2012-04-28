class PagesController < ApplicationController
  def home
    @var = Variable.new(params[:var])
    @var.save
    @variables = Variable.find(:all)
    render 'home'
  end
end
