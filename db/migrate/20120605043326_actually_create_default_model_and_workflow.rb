class ActuallyCreateDefaultModelAndWorkflow < ActiveRecord::Migration
  def up
    # This actually shouldn't do anything because these fixtures get created on the fly in the workflow controller.
  end

  def down
  end
end
