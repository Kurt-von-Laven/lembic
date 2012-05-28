class SerializeOldVariableExpressions < ActiveRecord::Migration
  def up
    Variable.transaction do
      for variable in Variable.find(:all)
        # Run expression objects that were persisted before the
        # expression_object column was set to serialize automatically
        # through the serializer.
        variable.expression_object = variable.expression_object
        variable.save
      end
    end
  end
  
  def down
    raise ActiveRecord::IrreversibleMigration, 'Can\'t distinguish variables added after serializer was added from variables added before serializer was added.'
  end
end
