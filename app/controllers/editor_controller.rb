class EditorController < ApplicationController
  
  DEFAULT_OPTIONS = {'workflow_id' => 1, 'array' => 0} # TODO: Grab the workflow ID out of the session state.
  
  def home
    # No changes
  end
  
  def delete
    puts 'Yo dawg.'
  end
  
  def variables
    if !params.nil?
      if !(params[:new_var].nil?)
        new_variable(params[:new_var])
      elsif !(params[:delete_var].nil?)
        puts @delete_var.inspect
        Variable.delete(@delete_var.id)
      end
    end
    @variables = Variable.find(:all)
    render 'variables'
  end
  
  def equations
    if !params.nil? and ! (params[:new_relationship].nil?)
	  Variable.find_by_name(params[:new_relationship]["var"]).update_relationship(params[:new_relationship])
    end
    @variables = Variable.find(:all)
    render 'equations'
  end
  
  def new_variable(var)
    now = Time.now
    Permission.where(:user_id => 1).first_or_create({'workflow_id' => 1, 'permissions' => 4, 'created_at' => now, 'updated_at' => now})
    User.where(:first_name => 'Michael').first_or_create({'last_name' => 'Jones', 'email' => 'qweoui@adsfqw.com', 'organization' => 'City Team',
                                                               'pwd_hash' => '21ad42ef24123589abcd', 'created_at' => now, 'updated_at' => now})
    Workflow.where(:name => 'Sample Workflow').first_or_create({'description' => 'This record should be removed eventually and is just for test purposes.',
                                                                     'created_at' => now, 'updated_at' => now})
    merged_var = DEFAULT_OPTIONS.merge(var)
    merged_var['created_at'] = now
    merged_var['updated_at'] = now
    merged_var['variable_type'] = merged_var['variable_type'].to_i
    merged_var['array'] = merged_var['array'].to_i
#	puts(merged_var.inspect)
	v = Variable.new(merged_var)
	
	v.save
	puts(v.errors.inspect)
   # Variable.create(merged_var)
  end
  
 
  
end
