

class Evaluator
  def eval (varname, globals, indices)
    my_formula = globals[varname][:formula]
  end
end


require "./parser"

p = Parser.new

relationships = {
  "foo" => { :formula => p.parse("bar*baz") },
  "bar" => { :formula => p.parse("baz+(1-a)") },
  "baz" => { :formula => p.parse("2*a-3") },
  "a" => { :formula => p.parse("6^2/2") }
}

relationships["foo"][:formula].eval("foo", relationships, nil)

puts "foo = #{relationships["foo"][:value]}, bar = #{relationships["bar"][:value]}, baz = #{relationships["baz"][:value]}, a = #{relationships["a"][:value]}"
