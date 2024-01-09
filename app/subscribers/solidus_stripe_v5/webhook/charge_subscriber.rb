# frozen_string_literal: true

require "solidus_stripe_v5/refunds_synchronizer"

module SolidusStripeV5
  module Webhook
    # Handlers for Stripe charge events.
    class ChargeSubscriber
      include Omnes::Subscriber
      include MoneyToStripeAmountConverter

      handle :"stripe.charge.refunded", with: :sync_refunds

      # Syncs Stripe refunds with Solidus refunds.
      #
      # @param event [SolidusStripeV5::Webhook::Event]
      # @see SolidusStripeV5::RefundsSynchronizer
      def sync_refunds(event)
        payment_method = event.payment_method
        stripe_payment_intent_id = event.data.object.payment_intent

        RefundsSynchronizer
          .new(payment_method)
          .call(stripe_payment_intent_id)
      end
    end
  end
end
