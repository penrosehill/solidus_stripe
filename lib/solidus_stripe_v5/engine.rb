# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusStripeV5
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace SolidusStripeV5
    engine_name 'solidus_stripe_v5'

    initializer "solidus_stripe_v5.add_payment_method", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << 'SolidusStripeV5::PaymentMethod'

      ::Spree::PermittedAttributes.source_attributes.prepend :stripe_payment_method_id
    end

    initializer "solidus_stripe_v5.pub_sub", after: "spree.core.pub_sub" do |app|
      require "solidus_stripe_v5/webhook/event"
      app.reloader.to_prepare do
        SolidusStripeV5::Webhook::Event.register(
          user_events: SolidusStripeV5.configuration.webhook_events,
          bus: Spree::Bus
        )
        SolidusStripeV5::Webhook::PaymentIntentSubscriber.new.subscribe_to(Spree::Bus)
        SolidusStripeV5::Webhook::ChargeSubscriber.new.subscribe_to(Spree::Bus)
      end
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
