require "./app/models/variable"

class StripIndicesFromVariableNames < ActiveRecord::Migration
  def change
    all_variables = Variable.find(:all)
    all_variables.each do |v|
      v.name = v.name.split(/\s*\[\s*/)[0]
      v.save(:validate => false)
    end
  end
end
