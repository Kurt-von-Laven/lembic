class CreateDefaultModelAndWorkflow < ActiveRecord::Migration
  def up
    #this is not the migration you're looking for
=begin
    drop_table :workflow_blocks
    default_model = Model.new({:name => "default model", :description => "default description"})
    default_workflow = Workflow.new({:name => "default workflow", :description => "default description"})
    for v in Variable.find(:all)
      v.model_id = default_model.id
      v.save
    end
    for b in Block.find(:all)
      next_sort_index = 0
      b.workflow_id = default_workflow.id
      b.sort_index = next_sort_index
      next_sort_index += 1
      b.save
    end
=end
  end

  def down
  end
end
