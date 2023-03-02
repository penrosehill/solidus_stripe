# frozen_string_literal: true

module SolidusStripe
  class PaymentMethod < ::Spree::PaymentMethod
    preference :api_key, :string
    preference :publishable_key, :string

    validates :available_to_admin, inclusion: { in: [false] }

    concerning :Actions do
      def actions
        %w[capture void credit]
      end

      def can_capture?(payment)
        payment.pending?
      end

      def can_void?(payment)
        payment.pending?
      end

      def can_credit?(payment)
        payment.completed? && payment.credit_allowed > 0
      end
    end

    concerning :Configuration do
      def partial_name
        "stripe"
      end

      alias cart_partial_name partial_name
      alias product_page_partial_name partial_name
      alias risky_partial_name partial_name

      def source_required?
        false
      end

      def payment_source_class
        PaymentSource
      end

      def gateway_class
        Gateway
      end
    end

    concerning :Order do
      def find_in_progress_payment_for(order)
        payments = order.payments
          .where.not(state: %w[completed invalid void]) # in_progress
          .where(payment_method: self)
          .order(:created_at)
          .entries

        *old_payments, payment = payments
        old_payments.each(&:invalidate!)

        if payment && payment.amount != order.total
          payment.cancel!
          payment = nil
        end

        payment
      end

      def create_in_progress_payment_for(order)
        transaction do
          intent = gateway.request do
            Stripe::PaymentIntent.create({
              amount: gateway.to_stripe_amount(
                order.display_total.money.fractional,
                order.currency,
              ),
              currency: order.currency,

              # The capture method should stay manual in order to
              # avoid capturing the money before the order is completed.
              capture_method: 'manual',
            })
          end

          order.payments
            .create!(
              payment_method: self,
              response_code: intent.id,
              amount: order.total,
            )
        end
      end

      def find_or_create_in_progress_payment_for(order)
        payment = find_in_progress_payment_for(order)
        intent = find_intent_for(payment) if payment

        payment = nil if intent.nil?
        payment = nil unless intent&.status == 'requires_payment_method'

        payment ||= create_in_progress_payment_for(order)
        payment
      end
    end

    concerning :Payment do
      def find_intent_for_order(order)
        payment = find_or_create_in_progress_payment_for(order)
        find_intent_for(payment) if payment
      end

      def find_intent_for(payment)
        unless payment.payment_method == self
          raise ArgumentError, "this payment is from another payment_method"
        end

        raise "missing payment intent id in response_code" if payment.response_code.blank?
        raise "bad payment intent id format" unless payment.response_code.start_with?('pi_')

        gateway.request { Stripe::PaymentIntent.retrieve(payment.response_code) }
      end

      def payment_profiles_supported?
        # We actually support them, but not in the way expected by Solidus and its ActiveMerchant legacy.
        false
      end

      def stripe_dashboard_url(payment)
        intent_id = payment.transaction_id
        path_prefix = '/test' if preferred_test_mode

        "https://dashboard.stripe.com#{path_prefix}/payments/#{intent_id}"
      end
    end
  end
end
