class Implication
  def initialize(implied_by)
    @implied_by = implied_by
  end

  def method_missing(permission, *args, &block)
    @implied_by.each do |implied_by_permission|
      Allowance.imply permission, implied_by_permission
    end
  end
end
