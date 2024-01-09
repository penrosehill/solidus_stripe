# frozen-string-literal: true

require "solidus_stripe_v5/seeds"

# rubocop:disable Rails/Output
puts "Creating refund reason for Stripe refunds"
SolidusStripeV5::Seeds.refund_reasons
# rubocop:enable Rails/Output
