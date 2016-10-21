require "allowances/version"

module Allowances
  module Fencable
    def self.included(base)
      base.extend ClassMethods
    end
    module ClassMethods
      def fencable
        has_many :user_personas, :dependent => :delete_all
        has_many :personas, :through => :user_personas

        has_one :allowance, :as => :allowable, :dependent => :delete

        include Fencable::InstanceMethods
      end
    end

    module InstanceMethods
      def is_allowed_to?(*args)
        args.flatten.any? do |arg|
          (allowance and allowance.allow?(arg)) or
            personas.any? do |persona|
              (persona.allowance and persona.allowance.allow?(arg))
            end
        end
      end
      def is_explicitly_allowed_to?(*args)
        args.flatten.any? do |arg|
          (allowance and allowance.send(arg)) or
            personas.any? do |persona|
              (persona.allowance and persona.allowance.send(arg))
            end
        end
      end
    end
  end
end
