puts "==== at the prompt, enter 'q' ===="
require "./app/controllers/parser"
require "./app/controllers/evaluator"
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
    assert_equal( "nil" , @p.prefix_form(".+1") )
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
  end
  
  def test_case_statements
    assert_equal( "CASE(1, 2, 3, 4)" , @p.prefix_form("{1: 2; 3: 4;}") )
    assert_equal( "CASE(<(1.2, foo), 3, else, 4)" , @p.prefix_form("{1.2 < foo:3;else: 4; }") )
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
  end
  
  def test_evaluator_case_statements
    assert_equal( 4, @e.eval_expression(@p.parse("{3>2:4;else:2;}"), nil, nil))
    assert_equal( 2, @e.eval_expression(@p.parse("{3<2:4;else:2;}"), nil, nil))
    assert_equal( 2, @e.eval_expression(@p.parse("{else:2;}"), nil, nil))
    assert_equal( 0, @e.eval_expression(@p.parse("{3<2:4;}"), nil, nil))
  end
  
end
