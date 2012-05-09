
require "./app/controllers/expression"

class Evaluator
  
  def eval_expression(exp, globals, indices)
    if exp.instance_of?(Expression)
      args = exp.args
      puts args.inspect
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
      elsif op == "[]"
        index_values = []
        args[1...args.length].each do |index_value|
          index_values << eval_expression(index_value, globals, indices)
        end
        return eval_variable(args[0], globals, index_values)
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
  
  def eval_variable (varname, globals, index_values)
    
    #  if variable value was cached previously, return the cached value
    if !globals[varname][:value].nil?
      return globals[varname][:value]
    end
    
    formula = globals[varname][:formula]
    
    # check if variable is an array or a singleton, and evaluate accordingly
    if globals[varname][:index_names].nil?
      #variable is a singleton
      result = eval_expression(formula, globals, nil)
    else
      #variable is an array; need to pass in index name-value mapping for expression evaluator
      indices = {}
      index_names = globals[varname][:index_names]
      if index_names.length != index_values.length
        raise "Wrong number of indices for array #{varname}: expected #{index_names.length} but was #{index_values.length}."
      end
      index_names.each_with_index do |index_name, i|
        indices[index_name] = index_values[i]
      end
      result = eval_expression(formula, globals, indices)
    end
    globals[varname][:value] = result
    return result
  end
  
end

require "./app/controllers/parser"

p = Parser.new
e = Evaluator.new

relationships = {
  "foo" => { :formula => p.parse("bar*baz") },
  "bar" => { :formula => p.parse("baz+(1-a)") },
  "baz" => { :formula => p.parse("2*a-3") },
  "a" => { :formula => p.parse("6^2/2") }
}

#relationships["foo"][:formula].eval("foo", relationships, nil)

e.eval_variable("foo", relationships, nil)

puts "foo = #{relationships["foo"][:value]}, bar = #{relationships["bar"][:value]}, baz = #{relationships["baz"][:value]}, a = #{relationships["a"][:value]}"
