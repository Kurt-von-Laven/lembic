class IndexName < ActiveRecord::Base
  attr_accessible :name, :variable_id, :sort_index
  belongs_to :variable
  validates_uniqueness_of :name, :scope => :variable_id
  validates_uniqueness_of :sort_index, :scope => :variable_id
  
  def self.create_from_declaration(dec, variable_id)
    #dec is a string like myvar[i, j, k]
    index_list = dec.split(/\s*\[\s*|\s*\]\s*/)[1]
    if index_list
      indices = index_list.split(/\s*,\s*/)
      indices.each_with_index do |index, i|
        new_index_name = IndexName.new({:name => index, :sort_index => i, :variable_id => variable_id})
        new_index_name.save
      end
    end
  end
  
end
