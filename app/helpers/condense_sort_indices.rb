module CondenseSortIndices
  
  def condense_sort_indices(scope)
    # Decrement higher sort_indices to prevent sparseness
    after_destroy do |destroyed|
      transaction do
        where("#{scope.to_s} = ? AND sort_index > ?", destroyed.send(scope), destroyed.sort_index).order(:sort_index).each do |record|
          record.sort_index -= 1
          record.save
        end
      end
    end
  end
  
end
