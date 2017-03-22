class DummyThing
  def initialize(name)
    @primary_name = name
  end

  def name # this method is made intentionaly long
    result = 'Dummy '

    if @primary_name.starts_with?('VIP')
      primary_name = @primary_name.sub('VIP ', '')
      upcased_name = primary_name.upcase
      result += upcased_name
    else
      result += @primary_name
    end

    result
  end

  def special_case_name
    'I am special!'
  end
end
