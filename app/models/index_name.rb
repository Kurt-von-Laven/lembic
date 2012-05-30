class IndexName < ActiveRecord::Base
  attr_accessible :name, :variable_id, :position
  belongs_to :variable
  validates_uniqueness_of :name, :scope => :variable_id
  validates_uniqueness_of :position, :scope => :variable_id
  
  def self.create_from_declaration(dec, variable_id)
    #dec is a string like myvar[i, j, k]
    index_list = dec.split(/\s*\[\s*|\s*\]\s*/)[1]
    indices = nil
    if index_list
      indices = index_list.split(/\s*,\s*/)
    end
    if indices
      indices.each_with_index do |index, i|
        new_index_name = IndexName.new({:name => index, :position => i, :variable_id => variable_id})
        new_index_name.save
      end
    end
  end
  
end