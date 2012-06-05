module CondenseSortIndices
  
  def self.included(base)
    # Decrement higher sort_indices to prevent sparseness
    base.after_destroy do |destroyed|
      base.transaction do
        base.where("#{INDEX_SCOPE.to_s} = ? AND sort_index > ?", destroyed.send(INDEX_SCOPE), destroyed.sort_index).order(:sort_index).each do |record|
          record.sort_index -= 1
          record.save
        end
      end
    end
  end
  
end
