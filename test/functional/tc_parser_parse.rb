
require "./app/helpers/parser"
require "./app/helpers/evaluator"
require "test/unit"

#Test
class TestParserParse < Test::Unit::TestCase
  
  def setup
    @p = Parser.new
    @e = Evaluator.new
  end
  
  def teardown
    # nada
  end
  
  def test_tokenizer
    assert_equal( ["1", "+", "2", "-", "3"], @p.tokenize("1+2-3") )
    assert_equal( ["1", "*", "-", "3"], @p.tokenize("1*-3") )
    assert_equal( ["-", "1", "*", "3"], @p.tokenize("-1*3") )
  end
  
  # 1+1
  # ~~~
  def test_add_two_numbers
    assert_equal( "+(1, 1)" , @p.prefix_form("1+1") )
  end
  
  # 1+2+3
  # ~~~~~
  def test_add_three_numbers
    assert_equal(  "+(+(1, 2), 3)" , @p.prefix_form("1+2+3") )
  end
  
  # 1.+2.2+3.325
  # 0.0+.2
  # DOESN'T PARSE: .+1
  # ~~~~~~~~~~~~~~
  def test_decimals
    assert_equal( "+(+(1., 2.2), 3.325)" , @p.prefix_form("1.+2.2+3.325") )
    assert_equal( "+(0.0, .2)" , @p.prefix_form("0.0+.2") )
    assert_raise(RuntimeError) { @p.prefix_form(".+1") }
  end
  
  def test_neg_numbers
    assert_equal( "-(0, 1)" , @p.prefix_form("-1") )
    assert_equal( "-(0, 1)" , @p.prefix_form("-(1)") )
    assert_equal( "*(1, -(0, 2))" , @p.prefix_form("1*-2") )
    assert_equal( "+(-(0, 1), 2)" , @p.prefix_form("(-1+2)") )
    assert_equal( "[](var, -(0, 1))" , @p.prefix_form("var[-1]") )
    assert_equal( "CASE(-(0, 1), 2)" , @p.prefix_form("{-1:2;}") )
    assert_equal( "CASE(-(0, 1), 2, 3, -(0, 4))" , @p.prefix_form("{-1:2;3:-4;}") )
  end
  
  def test_single_number_expression
    assert_equal( "(1)" , @p.prefix_form("1"))
  end
  
  def test_time
    assert_equal( "(1970_01_01_00_00_00)", @p.prefix_form("1970_01_01_00_00_00"))
    assert_equal( "(1970_01_01)", @p.prefix_form("1970_01_01"))
    assert_equal( "(00_00_00)", @p.prefix_form("00_00_00"))
  end
  
  def test_wacky_whitespace
    assert_equal( "+(+(1, 2), 3)" ,  @p.prefix_form(" \n 1 \n\t   + 2+3  \t ") )
  end
  
  def test_order_of_ops
    # addition and subtraction performed in the order they appear
    assert_equal( "+(-(1, 2), 3)" , @p.prefix_form("1-2+3") )
    assert_equal( "-(+(1, 2), 3)" , @p.prefix_form("1+2-3") )
    # ditto for multiplication, modulo, and division
    assert_equal( "/(*(1, 2), 3)" , @p.prefix_form("1*2/3") )
    assert_equal( "*(/(1, 2), 3)" , @p.prefix_form("1/2*3") )
    assert_equal( "%(*(1, 2), 3)" , @p.prefix_form("1*2%3") )
    assert_equal( "*(%(1, 2), 3)" , @p.prefix_form("1%2*3") )
    assert_equal( "%(/(1, 2), 3)" , @p.prefix_form("1/2%3") )
    assert_equal( "/(%(1, 2), 3)" , @p.prefix_form("1%2/3") )
    # exponents before other things
    assert_equal( "+(1, ^(2, 3))" , @p.prefix_form("1+2^3") )
    assert_equal( "*(1, ^(2, 3))" , @p.prefix_form("1*2^3") )
    # parens
    assert_equal( "-(1, +(2, 3))" , @p.prefix_form("1-(2+3)") )
    assert_equal( "*(1, +(2, 3))" , @p.prefix_form("1*(2+3)") )
    assert_equal( "^(1, +(2, 3))" , @p.prefix_form("1^(2+3)") )
  end

  def test_parens_get_removed
    assert_equal( @p.prefix_form("1") , @p.prefix_form("(((1)))") )
    assert_equal( "-(+(1, 2), 3)" , @p.prefix_form("((1+2)-3)"))
  end
  
  def test_array_indices
    assert_equal( "[](cats, 1)" , @p.prefix_form("cats[1]") )
    assert_equal( "[](cats, +(1, *(3, 5)))" , @p.prefix_form("cats[1+3*5]") )
    assert_equal( "[](cats, 1, 2)" , @p.prefix_form("cats[1, 2]") )
    assert_equal( "[](cats, 1, 2, 3, 4, 5)" , @p.prefix_form("cats[1, 2, 3, 4, 5]") )
    assert_equal( "[](cats, +(1, *(3, 5)), 7)" , @p.prefix_form("cats[1+3*5, 7]") )
    assert_equal( "[](a, [](b, [](c, 1)))" , @p.prefix_form("a[b[c[1]]]") )
  end
  
  def test_arrays_with_other_operations
    assert_equal( "+(x, [](cats, 1))" , @p.prefix_form("x+cats[1]") )
    assert_equal( "+([](cats, 1, 2, 3), x)" , @p.prefix_form("cats[1,2,3]+x") )
    assert_equal( "+(+(x, [](cats, 1, 2, 3)), x)" , @p.prefix_form("x+cats[1, 2, 3]+x") )
  end
  
  def test_case_statements
    assert_equal( "CASE(1, 2, 3, 4)" , @p.prefix_form("{1: 2; 3: 4;}") )
    assert_equal( "CASE(<(1.2, foo), 3, else, 4)" , @p.prefix_form("{1.2 < foo:3;else: 4; }") )
  end
  
  def test_literal_arrays
    assert_equal( "ARRAY(i, 1, 2, foo, 4)" , @p.prefix_form("[i|1,2,foo,4]"))
  end
  
  def test_evaluator_no_vars
    assert_equal( 4, @e.eval_expression(@p.parse("2+2"), nil, nil) )
    assert_equal( 8, @e.eval_expression(@p.parse("2*4"), nil, nil) )
    assert_equal( 14, @e.eval_expression(@p.parse("2+3*4"), nil, nil) )
    assert_equal( 20, @e.eval_expression(@p.parse("(2+3)*4"), nil, nil) )
    assert_equal( 2.0/3, @e.eval_expression(@p.parse("2/3"), nil, nil) )
    assert_equal( 8, @e.eval_expression(@p.parse("2^3"), nil, nil) )
    assert_equal( 2, @e.eval_expression(@p.parse("5%3"), nil, nil) )
    #equals
    assert_equal( 1, @e.eval_expression(@p.parse("1==1"), nil, nil) )
    assert_equal( 0, @e.eval_expression(@p.parse("1==0"), nil, nil) )
    #greater-than
    assert_equal( 1, @e.eval_expression(@p.parse("1>0"), nil, nil) )
    assert_equal( 0, @e.eval_expression(@p.parse("0>1"), nil, nil) )
    #less-than
    assert_equal( 1, @e.eval_expression(@p.parse("0<1"), nil, nil) )
    assert_equal( 0, @e.eval_expression(@p.parse("1<0"), nil, nil) )
    #greater-than-or-equals
    assert_equal( 1, @e.eval_expression(@p.parse("1>=0"), nil, nil) )
    assert_equal( 0, @e.eval_expression(@p.parse("0>=1"), nil, nil) )
    assert_equal( 1, @e.eval_expression(@p.parse("1>=1"), nil, nil) )
    assert_equal( 1, @e.eval_expression(@p.parse("1>=1"), nil, nil) )
    #less-than-or-equals
    assert_equal( 1, @e.eval_expression(@p.parse("0<=1"), nil, nil) )
    assert_equal( 0, @e.eval_expression(@p.parse("1<=0"), nil, nil) )
    assert_equal( 1, @e.eval_expression(@p.parse("1<=1"), nil, nil) )
    assert_equal( 1, @e.eval_expression(@p.parse("1<=1"), nil, nil) )
    #boolean and
    assert_equal( 0, @e.eval_expression(@p.parse("0&&0"), nil, nil) )
    assert_equal( 0, @e.eval_expression(@p.parse("0&&1"), nil, nil) )
    assert_equal( 0, @e.eval_expression(@p.parse("1&&0"), nil, nil) )
    assert_equal( 1, @e.eval_expression(@p.parse("1&&1"), nil, nil) )
    #boolean or
    assert_equal( 0, @e.eval_expression(@p.parse("0||0"), nil, nil) )
    assert_equal( 1, @e.eval_expression(@p.parse("0||1"), nil, nil) )
    assert_equal( 1, @e.eval_expression(@p.parse("1||0"), nil, nil) )
    assert_equal( 1, @e.eval_expression(@p.parse("1||1"), nil, nil) )
  end
  
  def test_evaluator_simple_vars
    assert_equal( 4, @e.eval_expression(@p.parse("2+two"), {"two" => { :formula => @p.parse("2") }}, nil))
    assert_equal( 4, @e.eval_expression(@p.parse("2+two"), {"two" => { :formula => @p.parse("1+1") }}, nil))
    assert_equal( 4, @e.eval_expression(@p.parse("2+two"), {"two" => { :value => 2 }}, nil))
    assert_equal( 4, @e.eval_expression(@p.parse("2+two"), {}, { "two" => 2 }))
    assert_equal( 3, @e.eval_expression(@p.parse("two+one"), {"two" => { :formula => @p.parse("one+one") }, "one" => {:value => 1}}, nil))
  end
  
  def test_evaluator_arrays
    assert_equal( 4, @e.eval_expression(@p.parse("arr[2]"), {"arr" => { :index_names => ["i"], :formula => @p.parse("2*i") }}, nil))
    assert_equal( 6, @e.eval_expression(@p.parse("arr[x+1]"), {"arr" => { :index_names => ["i"], :formula => @p.parse("2*i")}, "x" => {:value => 2}}, nil))
    #literal arrays
    assert_equal( 2, @e.eval_expression(@p.parse("[a|2,4,6]"), {}, {"a" => 0}))
    assert_equal( 6, @e.eval_expression(@p.parse("[a|2,4,6]"), {}, {"a" => 2}))
    assert_equal( 6, @e.eval_variable("arr", {"arr" => {:index_names => ["a"], :formula => @p.parse("[a|2,4,6]") }}, [2]))
    assert_raise(RuntimeError) { @e.eval_expression(@p.parse("[a|2,4,6]"), {}, {"a" => 3}) }
    assert_raise(RuntimeError) { @e.eval_expression(@p.parse("[a|2,4,6]"), {}, {"a" => -1}) }
    assert_raise(RuntimeError) { @e.eval_expression(@p.parse("[a|2,4,6]"), {}, {"a" => 0.5}) }
  end
  
  def test_evaluator_case_statements
    assert_equal( 4, @e.eval_expression(@p.parse("{3>2:4;else:2;}"), nil, nil))
    assert_equal( 2, @e.eval_expression(@p.parse("{3<2:4;else:2;}"), nil, nil))
    assert_equal( 2, @e.eval_expression(@p.parse("{else:2;}"), nil, nil))
    assert_equal( 0, @e.eval_expression(@p.parse("{3<2:4;}"), nil, nil))
  end
  
  def test_evaluator_builtin_functions
    assert_equal( 15, @e.eval_expression(@p.parse("SUM[arr, 0, 4]"), {"arr" => {:index_names => ["i"], :formula => @p.parse("[i|1,2,3,4,5]") }}, nil) )
  end
  
  def test_small_model
    output = @e.eval_all([{:name => "foo"}, {:name => "bar"}, {:name => "baz"}, {:name => "a"}],
                      {
                        "foo" => {:formula => @p.parse("bar+bar")},
                        "bar" => {:formula => @p.parse("baz*baz")},
                        "baz" => {:value => 2},
                        "a" => {:formula => @p.parse("b/c")},
                        "b" => {:formula => @p.parse("bar+2")},
                        "c" => {:formula => @p.parse("1+2")}
                      }
                      )
    assert_equal( 8, output["foo"][:value])
    assert_equal( 4, output["bar"][:value])
    assert_equal( 2, output["baz"][:value])
    assert_equal( 2, output["a"][:value])
    assert_equal( 6, output["b"][:value])
    assert_equal( 3, output["c"][:value])
  end
  
  def test_medium_model
    output = @e.eval_all([{:name => "o", :indices => {:min => 0, :max => 20}}],
                         {
                          "a" => {:index_names => ["i"], :formula => @p.parse("primes[i]*ints[i]-odds[i]")},
                          "ints" => {:index_names => ["i"], :formula => @p.parse("i+1")},
                          "odds" => {:index_names => ["i"], :formula => @p.parse("i*2+1")},
                          "primes" => {:index_names => ["i"], :formula => @p.parse("[i|2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73]")},
                          "o" => {:index_names => ["i"], :formula => @p.parse("a[i]+SUM[primes, 0, 20]")}
                         })
    assert_equal(1, output["a"][:values]["0"])
    assert_equal(3, output["a"][:values]["1"])
    assert_equal(10, output["a"][:values]["2"])
    assert_equal(21, output["a"][:values]["3"])
    assert_equal(713, output["o"][:values]["0"])
    assert_equal(715, output["o"][:values]["1"])
    assert_equal(722, output["o"][:values]["2"])
    assert_equal(733, output["o"][:values]["3"])
  end
  
  def test_evaluator_time
    assert_equal(0, @e.eval_expression(@p.parse("1970_01_01_00_00_00"), {}, {}))
    assert_equal(0, @e.eval_expression(@p.parse("00_00_00"), {}, {}))
    assert_equal(86400, @e.eval_expression(@p.parse("1970_01_02_00_00_00"), {}, {}))
    assert_equal(86400, @e.eval_expression(@p.parse("1970_01_02"), {}, {}))
  end
  
  def test_evaluator_nan
    assert((@e.eval_expression(@p.parse("NaN"), {}, {})).nan?)
  end
  
=begin
  def test_large_model
    output = @e.eval_all([{:name => "o", :indices => {:min => 0, :max => 9999}}],
                         {
                          "a" => {:index_names => ["i"], :formula => @p.parse("1+1+1+1+1+1+1+1+1+1")},
                          "b" => {:index_names => ["i"], :formula => @p.parse("a[i]*2-20+10")},
                          "c" => {:index_names => ["i"], :formula => @p.parse("-20*(i-i+1)")},
                          "d" => {:index_names => ["i"], :formula => @p.parse("i")},
                          "o" => {:index_names => ["i"], :formula => @p.parse("a[i]+b[i]+c[i]+d[i]")}
                         }
                         )
    puts output["o"][:values].inspect
  end
=end
end
