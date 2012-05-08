puts "==== at the prompt, enter 'q' ===="
require "./parser/parser"
require "test/unit"

#Test
class TestParserParse < Test::Unit::TestCase
  
  def setup
    @p = Parser.new
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
    assert_equal( 4, @p.parse("2+2").eval("blah", {}, nil))
    assert_equal( 8, @p.parse("2*4").eval("blah", {}, nil))
    assert_equal( 14, @p.parse("2+3*4").eval("blah", {}, nil))
    assert_equal( 20, @p.parse("(2+3)*4").eval("blah", {}, nil))
    assert_equal( 2.0/3, @p.parse("2/3").eval("blah", {}, nil))
    assert_equal( 8, @p.parse("2^3").eval("blah", {}, nil))
    assert_equal( 2, @p.parse("5%3").eval("blah", {}, nil))
    assert_equal( 1, @p.parse("1 ==1").eval("blah", {}, nil))
  end
  
  def test_evaluator_simple_vars
    assert_equal( 4, @p.parse("2+two").eval("blah", {"two" => { :formula => @p.parse("2") }}, nil))
    assert_equal( 4, @p.parse("2+two").eval("blah", {"two" => { :formula => @p.parse("1+1") }}, nil))
    assert_equal( 4, @p.parse("2+two").eval("blah", {"two" => { :value => 2 }}, nil))
    assert_equal( 4, @p.parse("two+two").eval("blah", {"two" => { :formula => @p.parse("1+1") }}, nil))
    assert_equal( 3, @p.parse("two+one").eval("blah", {"two" => { :formula => @p.parse("one+one") }, "one" => {:value => 1}}, nil))
  end
  
end
