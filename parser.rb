
### TODO
### Have Expression classes store type (e.g. number, variable, string), inputtable as parameter to Expression.new
### Change syntax for accessing multidimensional arrays from myvar[i][j][k] to myvar[i,j,k]
### Instead of using puts for error handling, throw exceptions.  Otherwise users who mess up will not know about it.

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
      if arg.class == "string"
        args_inspected << arg
      else
        args_inspected << arg.inspect
      end
    end
    return "#{@op}(#{args_inspected.join(", ")})"
  end
  
  def to_s
    return "..."
  end
  
  def match (*args)
    return false
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
  @@operators = [ /\^/, /[\*\/%]/, /[\+\-]/, /==|<=|>=|!=|<|>/, /&&|\|\|/ ] 
  
  def self.token_type(token)
    if token.class == "expression" then
      return :expression
    end
    num_regex = /^([\d]+(\.[\d]+){0,1})$/
    var_regex = /^([a-zA-Z_][a-zA-Z0-9_]*)$/
    #                  Y    Y    Y    Y     _M    M     _D    D     _H    H     _M    M     _S    S
    datetime_regex = /^[0-9][0-9][0-9][0-9](_[0-9][0-9](_[0-9][0-9](_[0-9][0-9](_[0-9][0-9](_[0-9][0-9](\.[0-9]*)?)?)?)?)?)?/
    op_regex = /^==|<=|>=|!=|&&|\|\||:|;|[\-\+\*\/%\^<>\{\}\(\)\[\]]$/
    if token.match(num_regex) != nil then
      #token is a number
      return :expression
    end
    if token.match(var_regex) != nil then
      #token is a variable name
      return :expression
    end
    if token.match(op_regex) != nil then
      #token is a math operator
      return :operator
    end
    puts "syntax error: unrecognized symbol "
    return nil
  end
  
  def error_inspect (array)
    ret = ""
    array.each do |a|
      ret << a.to_s
    end
    return ret
  end
  
  def tokenize (s)
    special_tokens = /(==|<=|>=|!=|&&|\|\||[;:\*\+\-\/\^%\(\)\[\]\{\}=<>])/
    s.gsub!(special_tokens, " \\1 ")
    s.gsub!(/^\s+|\s+$/, "") #remove leading and trailing whitespace
    return s.split(/\s+/)
  end
  
  # function match_tokens
  #
  # param pattern is an array like this:
  # [ :type, :expression, :regex, /^\+\-$/, :type, :expression ]
  # that is, the even-numbered elems (indexed from zero) denote the type of comparison to be applied to each element,
  # and the odd-numbered elems denote the object to be compared to the element.
  # The example above means: "first element should be of type :expression, second element should be "+" or "-", third element should be of type :expression".
  def match_tokens (tokens, start_index, pattern)
    pattern_error = "Whoa!  Someone typed a pattern wrong. This is not a user error; the dude who wrote this screwed up. You should probably email ben.christel@gmail.com and yell at him."
    if pattern.length % 2 == 1
      puts "error 1: number of elements in param pattern must be even; was #{pattern.length}"
      puts pattern_error
      return false
    end
    return false if tokens.length < start_index + pattern.length/2
    tokens[start_index...start_index+pattern.length/2].each_with_index do |tok, i|
      if pattern[i*2] == :type then
        return false unless Parser.token_type(tok) == pattern[i*2+1]
      elsif pattern[i*2] == :value then
        return false unless tok == pattern[i*2+1]
      elsif pattern[i*2] == :regex then
        return false unless tok.match pattern[i*2+1]
      else
        puts "error 2: invalid match criterion #{pattern[i*2]}"
        puts pattern_error
        return false
      end
    end
    return true
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
        
        # TODO: delete this when we're sure the new code works.
        #if currtoken < tokens.length - 2 &&
        #  Parser.token_type(tokens[currtoken]) == :expression &&
        #  Parser.token_type(tokens[currtoken+1]) == :operator && tokens[currtoken+1].match(@@operators[precedence]) &&
        #  Parser.token_type(tokens[currtoken+2]) == :expression &&
        #  (currtoken >= tokens.length - 3 || tokens[currtoken+3] != "[") #we don't want to add something to an array that hasn't been indexed yet!
        if match_tokens(tokens, currtoken, [:type, :expression, :regex, @@operators[precedence], :type, :expression]) &&
          (currtoken >= tokens.length - 3 || tokens[currtoken+3] != "[") #we don't want to add something to an array that hasn't been indexed yet!
        then
          tokens[currtoken..currtoken+2] = Expression.new(tokens[currtoken+1], [tokens[currtoken], tokens[currtoken+2]])
          loops_since_made_progress = 0
          made_progress = true
        end

        ### PARENTHESES ###
        
        if currtoken < tokens.length - 2 &&
          tokens[currtoken] == "(" && Parser.token_type(tokens[currtoken+1]) == :expression &&
          tokens[currtoken+2] == ")"
        then
          tokens[currtoken..currtoken+2] = tokens[currtoken+1]
          made_progress_at = precedence
          loops_since_made_progress = 0
          made_progress = true
        end
        
        ### CASE STATEMENTS ###
        
        if tokens[currtoken] == "{"
          # look ahead to close bracket; see if the stuff in between is a valid case statement
          look_ahead = 1
          is_case_stmt = true
          case_args = []
          while look_ahead < tokens.length && tokens[currtoken+look_ahead] != "}"
            if (look_ahead % 4 == 1 || look_ahead % 4 == 3) then
              if Parser.token_type(tokens[currtoken+look_ahead]) == :expression then
                case_args << tokens[currtoken+look_ahead]
              else
                is_case_stmt = false
                break
              end
            end
            if look_ahead % 4 == 2 then
              if tokens[currtoken+look_ahead] != ":" then
                is_case_stmt = false
                break
              end
            end
            if look_ahead % 4 == 0 then
              if tokens[currtoken+look_ahead] != ";" then
                is_case_stmt = false
                break
              end
            end
            look_ahead += 1
          end

          is_case_stmt = is_case_stmt && look_ahead % 4 == 1 && look_ahead > 1
          if is_case_stmt then
            tokens[currtoken..currtoken+look_ahead] = Expression.new("CASE", case_args)
            #currtoken -= 1
            made_progress_at = precedence
            loops_since_made_progress = 0
            made_progress = true
          end
        end
        
        ### ARRAY INDEXING ###
        
        # TODO: delete this when we're sure the new code works.
        #if currtoken < tokens.length - 3 &&
        #  Parser.token_type(tokens[currtoken]) == :expression &&
        #  tokens[currtoken+1] == "[" &&
        #  Parser.token_type(tokens[currtoken+2]) == :expression &&
        #  tokens[currtoken+3] == "]"
        if match_tokens(tokens, currtoken, [:type, :expression, :value, "[", :type, :expression, :value, "]"])
        then
          tokens[currtoken..currtoken+3] = Expression.new("[]", [tokens[currtoken], tokens[currtoken+2]])
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
    return tokens
  end
  
end

    
input_string = ""
p = Parser.new
while input_string != "q"
  print "Enter something to parse, or q to quit: "
  input_string = gets.chomp
  if input_string != "q"
    puts p.parse(input_string).inspect
  end
end

