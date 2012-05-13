
require "./app/controllers/expression"
require "./app/controllers/parser"

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
    if function_name == "SUM"
      array_name = params[0]
      min = params[1]
      max = params[2]
      sum = 0
      i = min
      while i <= max
        inc = eval_variable(array_name, globals, [i])
        sum += inc
        i += 1
      end
      return sum
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
          raise "Array index must be an integer.  Was #{index}."
        end
        if index < 0 || index >= elem_count
          raise "Array index #{index} is out of bounds.  Must be between 0 and #{elem_count-1}, inclusive."
        end
        return eval_expression(args[index+1], globals, indices)
      end
    else
      #exp is a string
      if exp.match(/^[\d]+(\.[\d]*){0,1}|\.[\d]+$/)
        #exp is a number
        return exp.to_f
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
    raise "Error: second parameter to eval_variable cannot be nil." if globals.nil?
    raise "Error: variable #{varname} doesn't exist." if globals[varname].nil?
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
    
    error_check_eval_variable_params(varname, globals, index_values)
    #  if variable value was cached previously, return the cached value
    if !globals[varname][:value].nil?
      return globals[varname][:value]
    end
    
    formula = globals[varname][:formula]
    
    raise "Error: formula for a variable must be an expression object." if !formula.instance_of?(Expression)
    
    # check if variable is an array or a singleton, and evaluate accordingly
    if globals[varname][:index_names].nil?
      #variable is a singleton
      result = eval_expression(formula, globals, nil)
      globals[varname][:value] = result
    else
      #variable is an array; need to pass in index name-value mapping for expression evaluator
      indices = {}
      index_names = globals[varname][:index_names]
      # if index_values is nil and we're trying to evaluate an array, it MAY be okay
      # as long as the array is being passed to an aggregator function.  Return
      # the name of the array so the aggregator can use it, and cross your fingers...
      if index_values.nil?
        return varname
      end
      if index_names.length != index_values.length
        raise "Wrong number of indices for array #{varname}: expected #{index_names.length} but was #{index_values.length}."
      end
      index_names.each_with_index do |index_name, i|
        indices[index_name] = index_values[i]
      end
      result = eval_expression(formula, globals, indices)
      globals[varname][:values] = {} if globals[varname][:values].nil?
      globals[varname][:values][index_values.join(",")] = result
    end
    return result
  end
  
  #
  # param outputs is an array that looks like this:
  # [{:name => "myvar"}, {:name => "myarray", :indices => {:min => 0, :max => 100 }}, ... ]
  #
  def eval_all(outputs, globals)
    outputs.each do |output|
      if output[:indices].nil?
        # output variable is a singleton
        eval_variable(output[:name], globals, nil)
      else
        # output is an array
        min_index = output[:indices][:min]
        max_index = output[:indices][:min]
        for curr in min_index..max_index
          eval_variable(output[:name], globals, [curr])
        end
      end
    end
    return globals
  end
  
end

