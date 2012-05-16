# Parser Pattern Syntax
#
# A parser pattern is a sequence of templates that the parser is trying to match to the input sequence.
# For example, a parser pattern could be designed to match the following sequence:
# "(", followed by one or zero tokens of type <expression>, followed by zero or more sequences of the form "," <expression>, followed by ")".
#
# Semi-formal syntax:
# parser_pattern -> [<munch_template>*]
# munch_template -> {:min_munches => <int>, :max_munches => <int>, :munch_pattern => <munch_pattern> }
# munch_pattern -> [<token_template>*]
# token_template -> {:criterion => <criterion>, :match => <object>, :capturing => <boolean> }
# criterion -> :type | :value | :regex
#
# A munch is a sub-pattern that matches several tokens at once.  A munch_template
# specifies a pattern for the munch, as well as the minimum and maximum number
# of times the munch can be repeated.  For example, a munch could be constructed that matches
# the pattern "a", "b" if the pattern repeats at most three times.


class ParserPatterns
  
  # ============================================================================
  def self.infix_operator_pattern(op_regex)
    return [
      {
        :min_munches => 1,
        :max_munches => 1,
        :munch_pattern =>
        [
          {
            :criterion => :type,
            :match => :expression,
            :capturing => true
          }
        ]
      },
      {
        :min_munches => 1,
        :max_munches => 1,
        :munch_pattern =>
        [
          {
            :criterion => :regex,
            :match => op_regex,
            :capturing => true
          }
        ]
      },
      {
        :min_munches => 1,
        :max_munches => 1,
        :munch_pattern =>
        [
          {
            :criterion => :type,
            :match => :expression,
            :capturing => true
          }
        ]
      }
    ]
  end
  
  # ============================================================================
  def self.array_pattern
  return [
          { # match variable name
            :min_munches => 1,
            :max_munches => 1,
            :munch_pattern => [{ :criterion => :type,
                                 :match => :expression,
                                 :capturing => true }]
          },
          {
            :min_munches => 1,
            :max_munches => 1,
            :munch_pattern => [{ :criterion => :value,
                                 :match => "[",
                                 :capturing => false }]
          },
          {
            :min_munches => 1,
            :max_munches => 1,
            :munch_pattern => [{ :criterion => :type,
                                 :match => :expression,
                                 :capturing => true }]
          },
          {
            :min_munches => 0,
            :max_munches => -1, #special value for infinitely many munches allowed
            :munch_pattern => [{ :criterion => :value,
                                 :match => ",",
                                 :capturing => false },
                               { :criterion => :type,
                                 :match => :expression,
                                 :capturing => true }]
          },
          {
            :min_munches => 1,
            :max_munches => 1,
            :munch_pattern => [{ :criterion => :value,
                                 :match => "]",
                                 :capturing => false }]
          }
        ]
  end
  
  # ============================================================================
  def self.case_pattern
    return [
      {
        :min_munches => 1,
        :max_munches => 1,
        :munch_pattern => [
          {
            :criterion => :value,
            :match => "{",
            :capturing => false
          }
        ]
      },
      {
        :min_munches => 1,
        :max_munches => -1,
        :munch_pattern => [
          {
            :criterion => :type,
            :match => :expression,
            :capturing => true
          },
          {
            :criterion => :value,
            :match => ":",
            :capturing => false
          },
          {
            :criterion => :type,
            :match => :expression,
            :capturing => true
          },
          {
            :criterion => :value,
            :match => ";",
            :capturing => false
          }
        ]
      },
      {
        :min_munches => 1,
        :max_munches => 1,
        :munch_pattern => [
          {
            :criterion => :value,
            :match => "}",
            :capturing => false
          }
        ]
      }
    ]
  end
  
  # ============================================================================
  def self.negative_expressions_pattern
    return [
      {
        :min_munches => 1,
        :max_munches => 1,
        :munch_pattern => [
          {
            :criterion => :value,
            :match => "-",
            :capturing => false
          }
        ]
      },
      {
        :min_munches => 1,
        :max_munches => 1,
        :munch_pattern => [
          {
            :criterion => :type,
            :match => :expression,
            :capturing => true
          }
        ]
      }
    ]
  end
  
  # ============================================================================
  def self.literal_array_pattern
    return [
      # opening bracket
      {
        :min_munches => 1,
        :max_munches => 1,
        :munch_pattern => [
          # {
          #  :criterion => :value,
          #  :match => "$",
          #  :capturing => false
          # },
          {
            :criterion => :value,
            :match => "[",
            :capturing => false
          }
        ]
      },
      
      # index variable name
      {
        :min_munches => 1,
        :max_munches => 1,
        :munch_pattern => [
          {
            :criterion => :type,
            :match => :expression,
            :capturing => true
          },
          {
            :criterion => :value,
            :match => "|",
            :capturing => false
          }
        ]
      },
      
      # 
      {
        :min_munches => 1,
        :max_munches => 1,
        :munch_pattern => [
          {
            :criterion => :type,
            :match => :expression,
            :capturing => true
          }
        ]
      },
      
      {
        :min_munches => 0,
        :max_munches => -1,
        :munch_pattern => [
          {
            :criterion => :value,
            :match => ",",
            :capturing => false
          },
          {
            :criterion => :type,
            :match => :expression,
            :capturing => true
          }
        ]
      },
      
      {
        :min_munches => 1,
        :max_munches => 1,
        :munch_pattern => [
          {
            :criterion => :value,
            :match => "]",
            :capturing => false
          }
        ]
      }
    ]
  end
  
  # ============================================================================
  def self.builtin_function_pattern
    return [
      {
        
      }
    ]
  end
end
