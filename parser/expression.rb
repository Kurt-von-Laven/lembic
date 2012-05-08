class Expression
  
  def initialize(op, args)
    @op = op
    @args = args
    if op == "+"
      # @op_func = plus.function_obj or something, I don't know ruby bloo blee bloo
    end
  end
  
  def inspect
    args_inspected = []
    @args.each do |arg|
      if arg.instance_of?(String) then
        args_inspected << arg
      else
        args_inspected << arg.inspect
      end
    end
    return "#{@op}(#{args_inspected.join(", ")})"
  end
  
  def self.bool_to_i (b)
    return 1 if b
    return 0
  end
  
  # returns the type of expression.  This can be:
  # # :number - literal integer or decimal
  # # :category - symbol for categorical variables; starts with @
  # # :variable - variable name
  # # :datetime - date and time in the format YYYY_MM_DD_HH_MM_SS (less significant portions will default to lowest possible value if not specified)
  def type
    return @type if @type != nil
    #add regex checks here to figure out type, and store it in @type
  end
  
  #convert an atomic expression (literal number, variable, symbol, or date) into a numeric type
  def atom_to_number(a)
    # hard case: if the atom is a variable that needs to be evaluated!
    # if the variable is already in @@callstack, we have a dependency cycle. Throw an exception!
    # otherwise, append the variable name to @@callstack
  end
  
  def dependencies
    dep_set = Set.new
    #special case: this is a [] node, and we need to return the specific array item this expression depends on
    if @op == "[]"
      # we can't, in general, know what specific array elements a formula depends on, because the array indices may themselves be complex formulas that depend on other formulas.
      # basically, dependency resolution and evaluation have to happen simultaneously O_O
    end
    @args.each do |arg|
      if arg.instance_of?(Expression)
        dep_set.union arg.dependencies
      end
    end
  end
  
  def eval(me, globals, indices)
    
    arg_cache = []
    
    @args.each do |arg|
      if arg.instance_of?(Expression)
        arg_cache << arg.eval(nil, globals, indices)
      elsif arg.match(/\d+/) then
        arg_cache << arg.to_i
      elsif !arg.to_f.nil?
        arg_cache << arg.to_f
      else
        # arg is a variable name
        if !globals[arg][:value].nil?
          arg_cache << globals[arg][:value]
        else
          arg_cache << globals[arg][:formula].eval(nil, globals, indices)
        end
      end
    end
    
    ## bunch of if-elsif statements go here, with logic for each possible operator
    
    if @op == "+"
      result = arg_cache[0] + arg_cache[1]
    elsif @op == "*"
      result = arg_cache[0] * arg_cache[1]
    elsif @op == "-"
      result = arg_cache[0] - arg_cache[1]
    elsif @op == "/"
      result = arg_cache[0] / arg_cache[1]
    elsif @op == "%"
      result = arg_cache[0] % arg_cache[1]
    elsif @op == "^"
      result = arg_cache[0] ** arg_cache[1]
    elsif @op == "<"
      result = self.bool_to_i arg_cache[0] < arg_cache[1]
    elsif @op == ">"
      result = self.bool_to_i arg_cache[0] > arg_cache[1]
    elsif @op == "=="
      result = self.bool_to_i arg_cache[0] == arg_cache[1]
    elsif @op == ">="
      result = self.bool_to_i arg_cache[0] >= arg_cache[1]
    elsif @op == "<="
      result = self.bool_to_i arg_cache[0] <= arg_cache[1]
    else
      puts "operator #{@op} doesn't exist or not yet implemented"
    end

    if !me.nil?
      #if indices.nil?
      #  globals[me][:value] = result
      #else
      #  globals[me.to_s+"#"+indices.join("#")] = result
      #end
    end
    return result
    
  end
  
end