require 'rubygems'
require "rails"
require 'active_record'
require "./app/models/variable"
require "test/unit"

class TestVariable < Test::Unit::TestCase
  def test_convert_letter_column_labels_to_numbers
    assert_equal(1, Variable.convert_letter_column_labels_to_numbers("a"))
    assert_equal(1, Variable.convert_letter_column_labels_to_numbers("A"))
    assert_equal(2, Variable.convert_letter_column_labels_to_numbers("b"))
    assert_equal(3, Variable.convert_letter_column_labels_to_numbers("c"))
    assert_equal(26, Variable.convert_letter_column_labels_to_numbers("Z"))
    assert_equal(27, Variable.convert_letter_column_labels_to_numbers("aa"))
    assert_equal(28, Variable.convert_letter_column_labels_to_numbers("aB"))
    assert_equal(29, Variable.convert_letter_column_labels_to_numbers("AC"))
  end
end
