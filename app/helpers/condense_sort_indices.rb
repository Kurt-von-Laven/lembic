module CondenseSortIndices
  
  def self.included(base)
    
  end
  
  def condense_sort_indices(scope)
    # Decrement higher sort_indices to prevent sparseness
    self.after_destroy do |destroyed|
      self.transaction do
        self.where("#{scope.to_s} = ? AND sort_index > ?", destroyed.send(scope), destroyed.sort_index).order(:sort_index).each do |record|
          record.sort_index -= 1
          record.save
        end
      end
    end
  end
  
end
