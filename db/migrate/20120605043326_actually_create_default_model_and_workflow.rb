class ActuallyCreateDefaultModelAndWorkflow < ActiveRecord::Migration
  def up
    default_model = Model.create({:name => "default model", :description => "default description"})
    default_workflow = Workflow.create({:name => "default workflow", :description => "default description"})
  end

  def down
  end
end
