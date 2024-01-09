# frozen_string_literal: true

SolidusStripeV5::Engine.routes.draw do
  scope ':slug' do
    get :after_confirmation, to: 'intents#after_confirmation'
    post :webhooks, to: 'webhooks#create', format: false
  end
end
