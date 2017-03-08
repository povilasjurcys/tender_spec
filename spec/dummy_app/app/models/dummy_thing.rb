class DummyThing
  def initialize(name)
    @primary_name = name
  end

  def name
    "Dummy #{@primary_name}"
  end
end
