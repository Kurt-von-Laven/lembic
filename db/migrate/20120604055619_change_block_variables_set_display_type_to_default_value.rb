class ChangeBlockVariablesSetDisplayTypeToDefaultValue < ActiveRecord::Migration
  
  ### Faux model allowing this migration to save data without running validations.
  ### Prevents issues associated with the current models trying to validate fields
  ### that aren't in the database yet as of this migration.
  ### For more info, see:
  ### http://guides.rubyonrails.org/migrations.html#using-models-in-your-migrations
  class BlockVariable < ActiveRecord::Base
    attr_accessible :display_type
  end
  
  def change
    
    BlockVariable.all.each do |bv|
      bv.update_attributes!(:display_type => 0)
    end
    
  end
end
