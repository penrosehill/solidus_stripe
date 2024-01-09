# frozen_string_literal: true

module SolidusStripeV5
  # Represents a webhook endpoint for a {SolidusStripeV5::PaymentMethod}.
  #
  # A Stripe webhook endpoint is a URL that Stripe will send events to. A store
  # could have multiple Stripe payment methods (e.g., a marketplace), so we need
  # to differentiate which one a webhook request targets.
  #
  # This model associates a slug with a payment method. The slug is appended
  # to the endpoint URL (`.../webhooks/:slug`) so that we can fetch the
  # correct payment method from the database and bind it to the generated
  # `Spree::Bus` event.
  #
  # We use a slug instead of the payment method ID to be resilient to
  # database changes and to avoid guessing about valid endpoint URLs.
  class SlugEntry < ::Spree::Base
    self.table_name = "solidus_stripe_slug_entries"

    belongs_to :payment_method, class_name: 'SolidusStripeV5::PaymentMethod'
  end
end
