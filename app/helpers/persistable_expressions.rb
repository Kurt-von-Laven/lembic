module PersistableExpressions
  
  def self.included(base)
    base.send(:attr_accessor, :expression_object_error)
    base.validates_each :expression_string do |record, attribute, value|
      if !record.expression_object_error.nil?
        record.errors.add(attribute, record.expression_object_error.message)
      end
    end
  end
  
  def expression_string=(new_expression_string)
    if !new_expression_string.nil?
      parser = Parser.new
      begin
        new_expression_object = parser.parse(new_expression_string)
      rescue ArgumentError => e
        self.expression_object_error = e
      else
        self[:expression_string] = new_expression_string
        self[:expression_object] = new_expression_object
        self.expression_object_error = nil
      end
    end
  end
  
  def expression_object=(new_expression_object)
    raise RuntimeError, 'You can\'t set the expression_object directly. Set the expression_string instead, and the expression_object will be updated automatically.'
  end
  
end
