class Period
  
  def initialize
    @h = {}
    curr
  end
  
  def begin
    @h[:begin]
  end

  def end
    @h[:end]
  end
  
  def curr
    t = Time.now
    if t.day <= 15
      @h[:begin] = Time.new(t.year, t.month, 1)
      @h[:end] = Time.new(t.year, t.month, 15)
    else
      @h[:begin] = Time.new(t.year, t.month, 16)
      @h[:end] = Time.new(t.year, t.month, Time.days_in_month(t.month))
    end
    self
  end

  def prev
    t = @h[:begin]
    if t.day <= 15
      @h[:begin] = Time.new(t.year, t.month-1, 16)
      @h[:end] = Time.new(t.year, t.month-1, Time.days_in_month(t.month-1))
    else
      @h[:begin] = Time.new(t.year, t.month, 1)
      @h[:end] = Time.new(t.year, t.month, 15)
    end
    self
  end
  
end