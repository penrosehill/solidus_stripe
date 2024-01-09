FactoryBot.definition_file_paths << SolidusStripeV5::Engine.root.join(
  'lib/solidus_stripe_v5/testing_support/factories'
).to_s

FactoryBot.reload
