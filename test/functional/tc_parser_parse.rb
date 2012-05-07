puts "==== at the prompt, enter 'q' ===="
require "./parser"
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
    assert_equal( ["1", "*", "(", "0", "-", "3", ")"], @p.tokenize("1*-3") )
    assert_equal( ["-1", "*", "3"], @p.tokenize("-1*3") )
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
  
  # 1*-2
  # ~~~~
  def test_neg_numbers_1
    assert_equal( "*(1, -(0, 2))" , @p.prefix_form("1*-2"))
  end
  
  def test_single_number_expression
    assert_equal( @p.prefix_form("1") , '"1"' )
  end
  
  def test_wacky_whitespace
    assert_equal( @p.prefix_form(" \n 1 \n\t   + 2+3  \t ") , "+(+(1, 2), 3)" )
  end
  
  def test_order_of_ops
    # addition and subtraction performed in the order they appear
    assert_equal( @p.prefix_form("1-2+3") , "+(-(1, 2), 3)" )
    assert_equal( @p.prefix_form("1+2-3") , "-(+(1, 2), 3)" )
    # ditto for multiplication, modulo, and division
    assert_equal( @p.prefix_form("1*2/3") , "/(*(1, 2), 3)" )
    assert_equal( @p.prefix_form("1/2*3") , "*(/(1, 2), 3)" )
    assert_equal( @p.prefix_form("1*2%3") , "%(*(1, 2), 3)" )
    assert_equal( @p.prefix_form("1%2*3") , "*(%(1, 2), 3)" )
    assert_equal( @p.prefix_form("1/2%3") , "%(/(1, 2), 3)" )
    assert_equal( @p.prefix_form("1%2/3") , "/(%(1, 2), 3)" )
    # exponents before other things
    assert_equal( @p.prefix_form("1+2^3") , "+(1, ^(2, 3))" )
    assert_equal( @p.prefix_form("1*2^3") , "*(1, ^(2, 3))" )
    # parens
    assert_equal( @p.prefix_form("1-(2+3)") , "-(1, +(2, 3))" )
    assert_equal( @p.prefix_form("1*(2+3)") , "*(1, +(2, 3))" )
    assert_equal( @p.prefix_form("1^(2+3)") , "^(1, +(2, 3))" )
  end

  def test_parens_get_removed
    assert_equal( @p.prefix_form("(((1)))") , @p.prefix_form("1") )
    assert_equal( @p.prefix_form("((1+2)-3)") , "-(+(1, 2), 3)" )
  end
  
  def test_array_indices
    assert_equal( @p.prefix_form("cats[1]") , "[](cats, 1)" )
    assert_equal( @p.prefix_form("cats[1+3*5]") , "[](cats, +(1, *(3, 5)))" )
    assert_equal( @p.prefix_form("cats[1, 2]") , "[](cats, 1, 2)" )
    assert_equal( @p.prefix_form("cats[1, 2, 3, 4, 5]") , "[](cats, 1, 2, 3, 4, 5)" )
    assert_equal( "[](cats, +(1, *(3, 5)), 7)" , @p.prefix_form("cats[1+3*5, 7]") )
  end
  
  def test_case_statements
    assert_equal( @p.prefix_form("{1: 2; 3: 4;}") , "CASE(1, 2, 3, 4)" )
    assert_equal( @p.prefix_form("{1.2 < foo:3;else: 4; }") , "CASE(<(1.2, foo), 3, else, 4)" )
  end
  
end
