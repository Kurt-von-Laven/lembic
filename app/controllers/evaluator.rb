

class Evaluator
  def eval (varname, globals, indices)
    my_formula = globals[varname][:formula]
  end
end


require "./parser.rb"
#require "./parser/parser"

p = Parser.new

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
relationships[output_name][:formula].eval(output_name, relationships, nil)
#relationships["foo"][:formula].eval("foo", relationships, nil)

# Print
puts "#{output_name} = #{relationships[output_name][:value]}"
#puts "foo = #{relationships["foo"][:value]}, bar = #{relationships["bar"][:value]}, baz = #{relationships["baz"][:value]}, a = #{relationships["a"][:value]}"
