module Fences
  DEFAULT_RESPONSE = :redirect
  ALLOWED_RESPONSE = [:redirect, :status_code]

  module Controller
    def self.included( recipient )
      recipient.extend( ControllerClassMethods )
      recipient.class_eval do
        include ControllerInstanceMethods
      end
    end

    module ControllerClassMethods
      def allow(*args, &block)
        if args.last.is_a? Hash
          allowances = args[0..-2]
          filter_args = args.last
        else
          allowances = args
          filter_args = {}
        end

        respond_with = filter_args.delete(:respond_with) || DEFAULT_RESPONSE

        before_filter(filter_args) do |controller|
          if block_given?
            controller.send(:allow, allowances, controller.instance_eval(&block), respond_with)
          else
            controller.send(:allow, allowances, true, respond_with)
          end
        end
      end
    end

    module ControllerInstanceMethods
      def allow(allowances, additional_condition, respond_with)
        unless (allowances.include?(:all) or current_user.is_allowed_to?(allowances)) and additional_condition
          respond_to do |format|
            format.html do
              case respond_with
              when :redirect
                flash[:notice] = "Permission denied."
                redirect_back_or_default(root_path)
              when :status_code
                render :text => 'Unauthorized.', :status => :unauthorized
              end
            end

            format.xml do
              render :text => 'Unauthorized.', :status => :unauthorized
            end

            format.json do
              render json: {}, status: :unauthorized
            end
          end
        end
      end
    end
  end

  module ViewInstanceMethods
    def allow(*allowances)
      if block_given? and current_user.is_allowed_to? allowances
        yield
      end
    end

    def explicitly_allow(*allowances)
      if block_given? and current_user.is_explicitly_allowed_to? allowances
        yield
      end
    end
  end
end
