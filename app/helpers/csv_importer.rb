require 'csv'

module CsvImporter
    
  INDEX = 'i' # The index used for constant arrays.
  
  def CsvImporter.parse_csv_to_array(csv_data, start_row_one_indexed, column_number_one_indexed, variable_type)
    start_row = start_row_one_indexed - 1
    column_number = column_number_one_indexed - 1
    converter = case variable_type
                when 0
                  nil
                when 1
                  :integer
                when 2
                  :float
                when 3
                  :date_time
                end
    parsed_data = CSV.parse(csv_data, :converters => converter)
    num_rows_desired = parsed_data.length - start_row
    if num_rows_desired < 1
      #start_row was greater than the greatest index in the array
      raise ArgumentError, "Start row out of bounds; can be at most #{parsed_data.length}" #remember that the user inputs one-indexed values!
    end
    desired_rows = parsed_data[start_row, num_rows_desired]
    desired_column = desired_rows.map {|r| r[column_number]}
    desired_column_with_nans = desired_column.map {|v| (v.nil? or (v == '')) ? Float::NAN : v}
    if converter == :date_time
      #convert to Lembic datetime
      desired_column_with_nans = desired_column_with_nans.collect{|i| date_convert(i)}
    end
    return desired_column_with_nans
  end
    
  def CsvImporter.parse_csv_expression(csv_data, start_row_one_indexed, column_number_one_indexed, variable_type)
    desired_values_as_str = parse_csv_to_array(csv_data, start_row_one_indexed, column_number_one_indexed, variable_type).join(', ')
    return "[ #{INDEX} | #{desired_values_as_str}]"
  end
  
  def CsvImporter.convert_letter_column_labels_to_numbers(input)
    raise ArgumentError, "parameter of convert_letter_column_labels_to_numbers must be a string" if !input.instance_of?(String)
    if input.match(/^[0-9]+$/)
      return input.to_i
    end
    if input.match(/^[a-zA-Z]+$/)
      multiplier = 1
      output = 0
      input.upcase.reverse.each_byte do |b|
	index_in_alphabet = b - 'A'[0].ord + 1
	output += index_in_alphabet * multiplier
	multiplier *= 26
      end
      return output
    end
    raise ArgumentError, "Column label must be specified as a decimal number or an Excel-style letter label."
  end
  
  def CsvImporter.date_convert(input)
    if !input.instance_of?(String)
      return input
    end
    # converts an Excel-formatted date/time string to Lembic format.
    date = nil
    #try a bunch of different formats
    date = try_date_conversion_format(input, "%m/%d/%y %H:%M") if date.nil?
    date = try_date_conversion_format(input, "%m/%d/%Y %H:%M") if date.nil?
    date = try_date_conversion_format(input, "%m/%d/%y %l:%M %p") if date.nil?
    date = try_date_conversion_format(input, "%m/%d/%Y %l:%M %p") if date.nil?
    date = try_date_conversion_format(input, "%H:%M") if date.nil?
    date = try_date_conversion_format(input, "%l:%M %p") if date.nil?
    date = try_date_conversion_format(input, "%H:%M:%S") if date.nil?
    date = try_date_conversion_format(input, "%l:%M:%S %p") if date.nil?
    conv = date.strftime("%Y_%m_%d_%H_%M_%S")
    return conv
    
  end
  
  def CsvImporter.try_date_conversion_format(input, fmt)
    date = nil
    begin
      date = DateTime.strptime(input, fmt)
    rescue
    end
    return date
  end
end
