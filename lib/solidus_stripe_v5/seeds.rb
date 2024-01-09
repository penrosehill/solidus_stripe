# frozen-string-literal: true

module SolidusStripeV5
  # Seed data to seamlessly integrate Solidus with Stripe.
  module Seeds
    # Default name for the `Spree::RefundReason` used for Stripe refunds.
    #
    # Changed via {SolidusStripeV5::Configuration#refund_reason_name}.
    #
    # @return [String]
    DEFAULT_STRIPE_REFUND_REASON_NAME = "Refund generated from Stripe"

    def self.refund_reasons
      Spree::RefundReason.find_or_create_by(
        name: DEFAULT_STRIPE_REFUND_REASON_NAME
      ) { _1.mutable = false }
    end
  end
end
