 module Allowable
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def allowable
      belongs_to :allowable, :polymorphic => true

      self.cattr_accessor :implications
      self.implications = {}

      include Allowable::InstanceMethods
      # extend Allowable::SingletonMethods
    end
  end

  # module SingletonMethods
  #   def imply(permission, by_permission)
  #     self.implications[permission] = [] unless self.implications.has_key? permission
  #     self.implications[permission] |= [by_permission]
  #   end
  #
  #   def allow(*args, &block)
  #     if block_given?
  #       implication = Implication.new(args)
  #       implication.instance_eval(&block)
  #     end
  #   end
  # end

  module InstanceMethods
    def allow?(permission)
      self.send(permission) or self.is_implied?(permission) or self.is_implied?(:all)
    end

    def is_implied?(permission)
      if self.implications.has_key? permission
        self.implications[permission].any? do |implied_by_permission|
          self.send(implied_by_permission)
        end
      else
        false
      end
    end
  end
end

