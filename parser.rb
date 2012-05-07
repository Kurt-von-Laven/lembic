
### TODO
### Have Expression classes store type (e.g. number, variable, string), inputtable as parameter to Expression.new
### Change syntax for accessing multidimensional arrays from myvar[i][j][k] to myvar[i,j,k]
### Instead of using puts for error handling, throw exceptions.  Otherwise users who mess up will not know about it.

require "./parser_patterns"

class ParseNode

  @args
  @operator
  @node_type
  
  # ==================================
  def initialize(_operator, _args)  
  # ==================================
  # params: array of ParseNodes or token strings to be the children of this node.
  # returns true if valid children were passed to create a node of the parse tree,
  # false otherwise
  
    self.operator = _operator
    self.args = _args
  end
end

class Expression

  def initialize(op, args)
    @op = op
    @args = args
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
  
  # returns the type of expression.  This can be:
  # # :number - literal integer or decimal
  # # :category - symbol for categorical variables; starts with @
  # # :variable - variable name
  # # :datetime - date and time in the format YYYY_MM_DD_HH_MM_SS (less significant portions will default to lowest possible value if not specified)
  def type
    return @type if @type != nil
  end
end


# [operation, arg1, arg2, ... , argn]
    
# ================ #   
#   PARSER CLASS   #
# ================ #

class Parser
  
  @tokens
  # operators are listed in order of precedence.
  @@operators = [ /^\^$/, /^[\*\/%]$/, /^[\+\-]$/, /^(==|<=|>=|!=|<|>)$/, /^(&&|\|\|)$/ ] 
  
  def self.token_type(token)
    if token.instance_of?(Expression) then
      return :expression
    end
    num_regex = /^(\-){0,1}[\d]+(\.[\d]*){0,1}|\.[\d]+$/
    var_regex = /^([a-zA-Z_][a-zA-Z0-9_]*)$/
    #                  Y    Y    Y    Y     _M    M     _D    D     _H    H     _M    M     _S    S
    datetime_regex = /^[0-9][0-9][0-9][0-9](_[0-9][0-9](_[0-9][0-9](_[0-9][0-9](_[0-9][0-9](_[0-9][0-9](\.[0-9]*)?)?)?)?)?)?/
    op_regex = /^==|<=|>=|!=|&&|\|\||:|;|[\-\+\*\/%\^<>\{\}\(\)\[\]]$/
    symbol_regex = /@[a-zA-Z_][a-zA-Z0-9_]*/
    if token.match(num_regex) != nil then
      #token is a number
      return :expression
    end
    if token.match(var_regex) != nil || token.match(symbol_regex) != nil then
      #token is a variable name
      return :expression
    end
    if token.match(op_regex) != nil then
      #token is a math operator
      return :operator
    end
    return nil
  end
  
  def error_inspect (array)
    ret = ""
    array.each do |a|
      if a.class == :expression then
        ret << "..."
      else
        ret << a.to_s
      end
    end
    return ret
  end
  
  def tokenize (s)
    #tricky case: get negative numbers to work right.  It's VITAL to gsub numbers before ops, or minus signs will get separated from negative numbers
    #neg_expressions = /([\+\-\*\/\^%\(\{\[:;^])\s*(\-[\d]+(\.[\d]*){0,1}|\-\.[\d]+)/
    #pos_numbers = /([\d]+(\.[\d]*){0,1}|\.[\d]+)/
    ops = /(==|<=|>=|!=|&&|\|\||[;:\*\+\-\/\^%\(\)\[\]\{\}=<>,])/
    #s =~ neg_numbers
    #puts "s was #{s}, neg_numbers matched #{$1}"
    #s.gsub!(neg_expressions, '\\1 (0 \\2)')
    s.gsub!(ops, " \\1 ")
    s.gsub!(/^\s+|\s+$/, "") #remove leading and trailing whitespace
    return s.split(/\s+/)
  end
  
  # munch_tokens takes a list of tokens, an index to start munching at, a pattern for munching, and the min and max number of times to match the pattern
  #
  # returns the number of tokens matched.
  
  def match_token? (token, criterion, comparee)
    if criterion == :type then
      return false unless Parser.token_type(token) == comparee
    elsif criterion == :value then
      return false unless token == comparee
    elsif criterion == :regex then
      return false unless token.respond_to?(:match)
      return false unless token.match(comparee)
    else
      return false
    end
    return true
  end
  
  def munch_tokens (tokens, start_index, pattern, min, max)
    currtoken = start_index
    pattern_index = 0
    all_tokens = []
    captured_tokens = []
    this_bite = []
    this_bite_captured = []
    munches = 0
    while currtoken < tokens.length && (max < 0 || munches <= max)
      break unless match_token?(tokens[currtoken], pattern[pattern_index][:criterion], pattern[pattern_index][:match])
      this_bite << tokens[currtoken]
      this_bite_captured << tokens[currtoken] if pattern[pattern_index][:capturing]
      currtoken += 1
      pattern_index = (pattern_index + 1) % (pattern.length)
      if pattern_index == 0 then
        if max == 0 #special case: the match is poison!  die right away
          return nil
        end
        munches += 1
        all_tokens.concat(this_bite)
        this_bite = []
        captured_tokens.concat(this_bite_captured)
        this_bite_captured = []
      end
    end
    return nil if munches < min
    return { :all => all_tokens, :captured => captured_tokens }
  end
  
  def matching_tokens (tokens, start_index, munches)
    currtoken = start_index
    munch_index = 0
    all_tokens = []
    captured_tokens = []
    while munch_index < munches.length
      munched = munch_tokens(tokens, currtoken, munches[munch_index][:munch_pattern], munches[munch_index][:min_munches], munches[munch_index][:max_munches])
      return { :matched => false } if munched.nil?
      all_tokens.concat(munched[:all])
      captured_tokens.concat(munched[:captured])
      munch_index += 1
      currtoken += munched[:all].length
      return { :matched => false } if currtoken > tokens.length #this should never be true, b/c munch_tokens is checking for out-of-bounds stuff
    end
    return { :matched => true, :all => all_tokens, :captured => captured_tokens }
  end
  
  # We use an iterative, bottom-up parsing strategy that runs in O(n^2) time in the number of input tokens.
  # The general strategy is to loop through all tokens, checking for patterns like <expression> <operator> <expression>,
  # and coalescing those patterns into expression objects.
  # To ensure that order of operations works correctly, we only look for operators with a specific precedence on any given
  # loop through the token array.  If we get through all the precedence values without making any progress in parsing, it means
  # there's a syntax error and parsing cannot continue.
  
  def parse (s)
    tokens = self.tokenize(s)
    precedence = 0
    made_progress = false # I wish we didn't have to have TWO flag variables for this... rewrite candidate
    loops_since_made_progress = 0
    while tokens.length > 1

      currtoken = 0
      while currtoken < tokens.length
        
        made_progress = false
        
        ### BASIC EXPRESSIONS W/ ORDER OF OPERATIONS ###
        
        matches = matching_tokens(tokens, currtoken, ParserPatterns.infix_operator_pattern(@@operators[precedence]))
        if matches[:matched] then
          tokens[currtoken..currtoken+2] = Expression.new(tokens[currtoken+1], [tokens[currtoken], tokens[currtoken+2]])
          loops_since_made_progress = 0
          made_progress = true
        end
        
        ### NEGATIVE NUMBERS ###
        
        matches = matching_tokens(tokens, currtoken, ParserPatterns.negative_expressions_pattern)
        if matches[:matched] && (currtoken == 0 || (tokens[currtoken-1].instance_of?(String) && tokens[currtoken-1].match(/^[\{\(\[\+\-\*\/\^%;:,]$/))) then
          tokens[currtoken..currtoken+1] = Expression.new("-", ["0", tokens[currtoken+1]])
          loops_since_made_progress = 0
          made_progress = true
        end

        ### PARENTHESES ###
        
        if currtoken < tokens.length - 2 &&
          tokens[currtoken] == "(" && Parser.token_type(tokens[currtoken+1]) == :expression &&
          tokens[currtoken+2] == ")"
        then
          tokens[currtoken..currtoken+2] = tokens[currtoken+1]
          loops_since_made_progress = 0
          made_progress = true
        end
        
        ### CASE STATEMENTS ###
        
        matches = matching_tokens(tokens, currtoken, ParserPatterns.case_pattern)
        if matches[:matched] then
          tokens[currtoken..currtoken+matches[:all].length] = Expression.new("CASE", matches[:captured])
          loops_since_made_progress = 0
          made_progress = true
        end
        
        ### ARRAY INDEXING ###
        
        matches = matching_tokens(tokens, currtoken, ParserPatterns.array_pattern)
        if matches[:matched] then
          tokens[currtoken..currtoken+matches[:all].length] = Expression.new("[]", matches[:captured])
          loops_since_made_progress = 0
          made_progress = true
        end
        
        currtoken += 1 unless made_progress
      end

      precedence = (precedence + 1) % @@operators.length

      if loops_since_made_progress > @@operators.length then
        puts "Syntax error!  I've replaced the parts I could understand with dots: #{error_inspect(tokens)}"
        return nil
      end
      
      loops_since_made_progress += 1
      
    end
    return tokens[0]
  end
  
  def prefix_form(s)
    return parse(s).inspect
  end
  
end

    
input_string = ""
p = Parser.new
while input_string != "q"
  print "Enter something to parse, or q to quit: "
  input_string = gets.chomp
  if input_string != "q"
    puts p.prefix_form(input_string)
  end
end

