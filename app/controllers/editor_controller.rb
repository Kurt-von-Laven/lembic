class EditorController < ApplicationController
  
  def equations
    if !params.nil?
      if !(params[:new_relationship].nil?)
        new_relationship = params[:new_relationship]
        variable_name = new_relationship['name']
        expression_string = new_relationship['expression_string']
        parser = Parser.new
        expression_object = parser.parse(expression_string)
        Variable.where(:name => variable_name).update_all(:expression_string => expression_string, :expression_object => expression_object)
      elsif !(params[:new_variable].nil?)
        Variable.create_from_form(params[:new_variable])
      end
    end
    @variables = Variable.find(:all)
    render 'equations'
  end
  
  def delete_variable
    if !params.nil? and !(params[:id].nil?)
      Variable.delete(params[:id]) # TODO: Check that this ID is valid.
    end
    @variables = Variable.find(:all)
    redirect_to 'equations'
  end
  
  def delete_relationship
    if !params.nil? and !(params[:id].nil?)
      Variable.update(params[:id], {:expression_string => nil, :expression_object => nil})
      redirect_to 'equations'
    end
  end
  
end
