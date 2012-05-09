
require "./app/controllers/expression"

class Evaluator
  
  def bool_to_i(b)
    return 1 if b
    return 0
  end
  
  def eval_expression(exp, globals, indices)
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
      elsif op == "&&"
        return bool_to_i(eval_expression(args[0], globals, indices) != 0 && eval_expression(args[1], globals, indices) != 0)
      elsif op == "||"
        return bool_to_i(eval_expression(args[0], globals, indices) != 0 || eval_expression(args[1], globals, indices) != 0)
      elsif op == "[]"
        index_values = []
        args[1...args.length].each do |index_value|
          index_values << eval_expression(index_value, globals, indices)
        end
        return eval_variable(args[0], globals, index_values)
      elsif op == "CASE"
        for case_index in 0...args.length/2
          if args[case_index*2] == "else" || eval_expression(args[case_index*2], globals, indices) != 0
            return eval_expression(args[case_index*2+1], globals, indices)
          end
        end
        # if we got here, none of the cases were true and there was no else; return arbitrary default
        return 0
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

=begin
relationships = {
  "foo" => { :formula => p.parse("bar*baz") },
  "bar" => { :formula => p.parse("baz+(1-a)") },
  "baz" => { :formula => p.parse("2*a-3") },
  "a" => { :formula => p.parse("6^2/2") }
}
=end

relationships = {}

# Prompt user for variable names and expressions
while true do
  
  # Prompt for a variable name ("" to finish)
  puts "Enter a name for a variable (empty name to finish): "
  name = gets.chomp
  if name.length == 0 then
    break
  end

  # Prompt for an expression for this variable
  puts "Enter an expression for #{name}: "
  expr = gets.chomp

  # Add this variable and expression to the relationships hash
  relationships[name] = { :formula => p.parse(expr) }

end

# Ask which variable to solve for
puts "Enter the exact name of the output variable you want to solve for: "
output_name = gets.chomp

# Solve
#e.eval_variable(output_name, relationships, nil)
#e.eval_variable("foo", relationships, nil)
relationships[output_name][:formula].eval(output_name, relationships, nil)
#relationships["foo"][:formula].eval("foo", relationships, nil)

# Print
puts "#{output_name} = #{relationships[output_name][:value]}"
#puts "foo = #{relationships["foo"][:value]}, bar = #{relationships["bar"][:value]}, baz = #{relationships["baz"][:value]}, a = #{relationships["a"][:value]}"

