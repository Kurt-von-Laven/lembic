class ParserPatterns
  
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
end
