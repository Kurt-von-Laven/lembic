
### TODO
### Instead of using puts for error handling, throw exceptions.  Otherwise users who mess up will not know about it.


require "./parser_patterns"
require "./expression"

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
  
  # returns true iff token parameter matches the comparee parameter by the given criterion
  # criterion may be:
  #   :type, which only restricts the token to be an expression or an operator.  Comparee may be :expression or :operator
  #   :value, which compares the string value of token to that of comparee.
  #   :regex, which checks whether token matches the regex specified in comparee
  
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
  
  # munch_tokens starts at the given start_index in the list of tokens, and compares the tokens after that position to the given pattern.
  # The pattern loops if there are more tokens than pattern elements, so the pattern [a, b, c] would match the first six elements of [a, b, c, a, b, c, d].
  #
  # The pattern always starts matching at the start_index, so if start_index is 0, the pattern is [a, b], and the token sequence is [c, a, b],
  # munch_tokens will return nil, indicating that there is no match at the specified position.
  #
  # returns a hash with keys :all and :captured, or nil if the match failed.
  #   :all stores all the tokens
  #   :captured stores only the tokens indicated as capturing by the pattern
  # the match fails if:
  #   the pattern was not found min times
  #   max was 0 and the pattern was found
  # 
  
  def munch_tokens (tokens, start_index, pattern, min, max)
    currtoken = start_index
    pattern_index = 0
    all_tokens = []
    captured_tokens = []
    # a bite is a sequence of tokens that matches a single repetition of the given pattern
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
    if tokens[0].instance_of?(String)
      tokens[0] = Expression.new(nil, [tokens[0]])
    end
    return tokens[0]
  end
  
  def prefix_form(s)
    return parse(s).inspect
  end
  
end

=begin
input_string = ""
p = Parser.new
while input_string != "q"
  print "Enter something to parse, or q to quit: "
  input_string = gets.chomp
  if input_string != "q"
    puts p.prefix_form(input_string)
  end
end
=end

