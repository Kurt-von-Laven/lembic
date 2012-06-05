
require Rails.root.join('app/helpers/expression')
require Rails.root.join('app/helpers/parser')
require "date"

# Class Evaluator
# 
# - The only function you should need to call to evaluate a workflow is
#   Evaluator::eval_variable.
#

class Evaluator
  
  def initialize
    @p = Parser.new
  end
  
  def bool_to_i(b)
    return 1 if b
    return 0
  end
  
  def eval_builtin_function(function_name, globals, params)
    
    #setup for array aggregators
    if params.length == 3
      array_name = params[0]
      min_i = params[1]
      max_i = params[2]
    end
    
    if function_name == "SUM"
      if params.length != 3
        raise ArgumentError, "Wrong number of arguments to SUM: expected 3 but found #{params.length}."
      end
      sum = 0
      i = min_i
      while i <= max_i
        inc = eval_variable(array_name, globals, [i])
        sum += inc
        i += 1
      end
      return sum
    
    elsif function_name == "MAX"
      if params.length != 3
        raise ArgumentError, "Wrong number of arguments to MAX: expected 3 but found #{params.length}."
      end
      i = min_i
      max = eval_variable(array_name, globals, [i])
      while i < max_i
        candidate = eval_variable(array_name, globals, [i])
        if candidate > max
          max = candidate
        end
        i += 1
      end
      return max
    
    elsif function_name == "MIN"
      if params.length != 3
        raise ArgumentError, "Wrong number of arguments to MIN: expected 3 but found #{params.length}."
      end
      i = min_i
      min = eval_variable(array_name, globals, [i])
      while i < max_i
        candidate = eval_variable(array_name, globals, [i])
        if candidate < min
          min = candidate
        end
        i += 1
      end
      return min
    
    elsif function_name == "DAY"
      if params.length != 1
        raise ArgumentError, "Wrong number of arguments to DAY: expected 1 but found #{params.length}."
      end
      begin
        datetime = Time.at(params[0]).utc
      rescue ArgumentError
        raise ArgumentError, "Argument of DAY must be a date or number."
      end
      daynum = datetime.wday
      if daynum == 0
        return :Sunday
      elsif daynum == 1
        return :Monday
      elsif daynum == 2
        return :Tuesday
      elsif daynum == 3
        return :Wednesday
      elsif daynum == 4
        return :Thursday
      elsif daynum == 5
        return :Friday
      elsif daynum == 6
        return :Saturday
      end
      
    elsif function_name == "DAYNUM"
      if params.length < 1 || params.length > 3
        raise ArgumentError, "Wrong number of arguments to DAYNUM: expected 1 to 3 but found #{params.length}."
      end
      begin
        datetime = Time.at(params[0]).utc
      rescue ArgumentError
        raise ArgumentError, "First argument of DAYNUM must be a date or number."
      end
      daynum = datetime.wday #0 = Sunday
      week_start = params[1]
      index_from = params[2]
      index_from = 1 if !index_from
      if week_start == :Sunday || week_start == nil
        return daynum + index_from
      elsif week_start == :Monday
        return (daynum - 1) % 7 + index_from
      elsif week_start == :Tuesday
        return (daynum - 2) % 7 + index_from
      elsif week_start == :Wednesday
        return (daynum - 3) % 7 + index_from
      elsif week_start == :Thursday
        return (daynum - 4) % 7 + index_from
      elsif week_start == :Friday
        return (daynum - 5) % 7 + index_from
      elsif week_start == :Saturday
        return (daynum - 6) % 7 + index_from
      else
        raise ArgumentError, "Second argument of DAYNUM must specify the day the week starts on; must be one of {@Monday, @Tuesday, @Wednesday, @Thursday, @Friday, @Saturday, @Sunday}."
      end
      return daynum
      
    elsif function_name == "MONTH"
      if params.length != 1
        raise ArgumentError, "Wrong number of arguments to MONTH: expected 1 but found #{params.length}."
      end
      begin
        datetime = Time.at(params[0]).utc
      rescue ArgumentError
        raise ArgumentError, "Argument of MONTH must be a date or number."
      end
      return datetime.month
    
    elsif function_name == "HOUR"
      if params.length != 1
        raise ArgumentError, "Wrong number of arguments to HOUR: expected 1 but found #{params.length}."
      end
      begin
        datetime = Time.at(params[0]).utc
      rescue ArgumentError
        raise ArgumentError, "Argument of HOUR must be a date or number."
      end
      return datetime.hour
    
    end
    return nil
  end
  
  # function eval_expression
  #
  # params
  #
  # returns : numeric value of the exp param
  def eval_expression(exp, globals, indices)
    if !indices.nil?
    end
    if exp.nil?
      return 0.0/0.0 #NaN
    end
    if exp.instance_of?(Expression)
      args = exp.args
      op = exp.op
      if op.nil?
        return eval_expression(args[0], globals, indices)
      elsif op == "+"
        return eval_expression(args[0], globals, indices) + eval_expression(args[1], globals, indices)
      elsif op == "-"
        return eval_expression(args[0], globals, indices) - eval_expression(args[1], globals, indices)
      elsif op == "*"
        return eval_expression(args[0], globals, indices) * eval_expression(args[1], globals, indices)
      elsif op == "/"
        return eval_expression(args[0], globals, indices) / eval_expression(args[1], globals, indices)
      elsif op == "%"
        return eval_expression(args[0], globals, indices) % eval_expression(args[1], globals, indices)
      elsif op == "^"
        return eval_expression(args[0], globals, indices) ** eval_expression(args[1], globals, indices)
      elsif op == "=="
        return bool_to_i(eval_expression(args[0], globals, indices) == eval_expression(args[1], globals, indices))
      elsif op == "<"
        return bool_to_i(eval_expression(args[0], globals, indices) < eval_expression(args[1], globals, indices))
      elsif op == ">"
        return bool_to_i(eval_expression(args[0], globals, indices) > eval_expression(args[1], globals, indices))
      elsif op == "<="
        return bool_to_i(eval_expression(args[0], globals, indices) <= eval_expression(args[1], globals, indices))
      elsif op == ">="
        return bool_to_i(eval_expression(args[0], globals, indices) >= eval_expression(args[1], globals, indices))
      elsif op == "!="
        return bool_to_i(eval_expression(args[0], globals, indices) != eval_expression(args[1], globals, indices))
      elsif op == "&&"
        return bool_to_i(eval_expression(args[0], globals, indices) != 0 && eval_expression(args[1], globals, indices) != 0)
      elsif op == "||"
        return bool_to_i(eval_expression(args[0], globals, indices) != 0 || eval_expression(args[1], globals, indices) != 0)
      elsif op == "[]"
        index_values = []
        args[1...args.length].each do |index_value|
          index_values << eval_expression(index_value, globals, indices)
        end
        builtin_return = eval_builtin_function(args[0], globals, index_values)
        return builtin_return unless builtin_return.nil?
        return eval_variable(args[0], globals, index_values)
      elsif op == "CASE"
        for case_index in 0...args.length/2
          if args[case_index*2] == "else" || eval_expression(args[case_index*2], globals, indices) != 0
            return eval_expression(args[case_index*2+1], globals, indices)
          end
        end
        # if we got here, none of the cases were true and there was no else; return arbitrary default
        return 0
      elsif op == "ARRAY"
        elem_count = args.length - 1
        index = eval_expression(args[0], globals, indices)
        if index.to_i != index
          raise ArgumentError, "Array index must be an integer.  Was #{index}."
        end
        if index < 1 || index > elem_count
          raise ArgumentError, "Array index #{index} is out of bounds.  Must be between 1 and #{elem_count}, inclusive."
        end
        return eval_expression(args[index], globals, indices)
      end
    else
      #exp is a string
      if exp[0] == ?@
        #exp is a symbol
        return exp[1..-1].intern
      elsif exp == "NaN"
        #exp is nan
        return 0.0/0.0
      elsif exp.match(/^[\d]+(\.[\d]*){0,1}$|^\.[\d]+$/)
        #exp is a number
        return exp.to_f
      elsif exp.match(/^\d\d\d\d_\d\d_\d\d_\d\d_\d\d_\d\d$/)
        #exp is a date and time
        return DateTime.strptime(exp+" +0", "%Y_%m_%d_%H_%M_%S %z").to_time.to_f
      elsif exp.match(/^\d\d\d\d_\d\d_\d\d$/)
        #exp is a date
        return DateTime.strptime(exp+"_00_00_00 +0", "%Y_%m_%d_%H_%M_%S %z").to_time.to_f
      elsif exp.match(/^\d\d\_\d\d_\d\d$/)
        #exp is a time
        return DateTime.strptime("1970_01_01_"+exp+" +0", "%Y_%m_%d_%H_%M_%S %z").to_time.to_f
      else
        #exp is a variable
        if !indices.nil? && !indices[exp].nil?
          #exp is an array index variable
          return indices[exp]
        end
        return eval_variable(exp, globals, nil)
      end
    end
  end
  
  def error_check_eval_variable_params(varname, globals, index_values)
    if !varname.instance_of?(String)
      raise ArgumentError, "Internal Error: Variable name must be specified as a string, but was a #{varname.class}.  Please notify Lembic of this error."
    end
    raise ArgumentError, "Error: second parameter to eval_variable cannot be nil." if globals.nil?
    raise ArgumentError, "Error: variable #{varname} doesn't exist." if globals[varname].nil?
  end
  
  #
  # function eval_variable
  #
  # Evaluates a particular variable in the context of a set of input values.
  # Also evaluates all variables the given variable depends on, so you can get those values too.
  #
  # Params:
  # - String varname - the name of the variable to be evaluated
  # - Hash globals - stores the formulas and/or input values for all the variables in the model.  Format described below.
  # - Hash index_values - Nil if the variable being evaluated is a singleton (i.e. not an array).  If we're evaluating an array,
  #                       index_values should map the index variable names (as strings) to numeric values.
  #
  # Returns:
  # - The value of the variable specified as varname.  Also populates the globals hash with the values of the variables that get 
  #   computed as a side effect of evaluating the specified variable.
  #
  # globals format: { "varname1" => { :formula => <Expression> :value => <Numeric> }, "varname2" => ... , ... "varnameN" => ... }
  #
  def eval_variable (varname, globals, index_values)
    puts "IN EVAL_VARIABLE"
    error_check_eval_variable_params(varname, globals, index_values)
    #  if variable value was cached previously, return the cached value
    if !globals[varname][:value].nil?
      return globals[varname][:value]
    end

    formula = globals[varname][:formula]
    
    raise ArgumentError, "Error: formula for variable `#{varname}` must be an expression object.  Was #{formula.class}" if !formula.instance_of?(Expression)
    
    # check if variable is an array or a singleton, and evaluate accordingly
    puts "globals[varname]: "+globals[varname].inspect
    puts "globals[varname][:index_names]: "+globals[varname][:index_names].inspect
    index_names = globals[varname][:index_names]
    if index_names.nil? || (index_names.instance_of?(Array) && index_names.length == 0)      #variable is a singleton
      result = eval_expression(formula, globals, nil)
      globals[varname][:value] = result
      puts "globals[varname][:value]: "+globals[varname][:value].inspect
    else
      #variable is an array; need to pass in index name-value mapping for expression evaluator
      indices = {}
      # if index_values is nil and we're trying to evaluate an array, it MAY be okay
      # as long as the array is being passed to an aggregator function.  Return
      # the name of the array so the aggregator can use it, and cross your fingers...
      if index_values.nil?
        return varname
      end
      if index_names.length != index_values.length
        raise ArgumentError, "Wrong number of indices for array #{varname}: expected #{index_names.length} but was #{index_values.length}."
      end
      index_names.each_with_index do |index_name, i|
        indices[index_name] = index_values[i]
      end
      values_key = index_values.join(",")
      result = eval_expression(formula, globals, indices)
      globals[varname][:values] = {} if globals[varname][:values].nil?
      globals[varname][:values][index_values] = result
    end
    return result
  end
  
  #
  # param outputs is an array that looks like this:
  # [{:name => "myvar"}, {:name => "myarray", :indices => {:min => 0, :max => 100 }}, ... ]
  #
  def eval_all(outputs, globals)
    puts "GLOBALS: "+globals.inspect
    puts "OUTPUTS: "+outputs.inspect
    outputs.each do |output|
      if output[:indices].nil?
        # output variable is a singleton
        eval_variable(output[:name], globals, nil)
      else
        # output is an array
        min_index = output[:indices][:min]
        max_index = output[:indices][:max]
        curr = min_index
        while curr <= max_index do
          eval_variable(output[:name], globals, [curr])
          curr += 1
        end
      end
    end
    return globals
  end
  
end

