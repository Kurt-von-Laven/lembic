# CSV to lembic converter
# This method takes in the data of a CSV file in array form, and outputs an array of strings.
# Each string is an expression in the Lembic scripting language that represents
# one column (or row, as specified) of the file as an array.
#
# param index_var_names stores a list of index variable names to be used as 

module CSV
  def to_lembic (file_data, index_var_names)
    if index_var_names.length != file_data[0].length
      raise "Exactly one index variable name must be specified for each column of data"
    end
    formulas = []
    currcol = 0
    
    # populate cols array; each column of the file is stored as an array
    while currcol < file_data[0].length
      formulas[currcol] = ["{"]
      index_var = index_var_names[currcol]
      file_data_each_with_index do |row|
        formulas[currcol] << index_var << "==" << row[currcol]
      end
      currcol += 1
    end
    
    formulas = []
    currcol = 0
    while currcol < cols.length
      
    end
  end
end
