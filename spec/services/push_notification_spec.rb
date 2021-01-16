# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PushNotification do
  let(:args) {
    { token: 'ExponentPushToken[GCPOCHK-aKfYgHzwiL_AQO]', habit_name: 'Run everyday', body: 'Run everyday!',
      sound: 'default' }
  }
  let(:push) { described_class.new(token: args[:token], habit_name: args[:habit_name], **args) }

  describe 'initialize' do
    context 'when fields are valid' do
      it { expect(push.token).to eq(args[:token]) }
      it { expect(push.client).to be_instance_of(Exponent::Push::Client) }
      it { expect(push.title).to eq('Run everyday') }
      it { expect(push.sound).to eq('default') }
      it { expect(push.body).to eq('Run everyday!') }
    end

    context 'when defaults are not given' do
      let(:args) { { token: Faker::Internet.uuid, habit_name: 'Run everyday' } }

      it { expect(push.sound).to eq('default') }
      it { expect(push.body).to eq('Do the Habit!') }
    end

    context 'when required fields are not given' do
      it 'ArgumentError is raised for Token' do
        args[:token] = nil
        expect { push }.to raise_error(ArgumentError, 'Token cannot be nil')
      end

      it 'ArgumentError is raised for Habit Name' do
        args[:habit_name] = nil
        expect { push }.to raise_error(ArgumentError, 'Habit Name cannot be nil')
      end
    end
  end

  describe '.send' do
    let(:message) { [{ to: push.token, sound: push.sound, body: push.body, title: push.title }] }

    before do
      allow(push.client).to receive(:send_messages).with(message) { handler }
    end

    context 'when token is valid' do
      let(:handler) do
        Handler.new(code: 200,
                    response_body: success_body.to_json,
                    receipt_ids: [receipt])
      end

      it { expect { push.client }.not_to raise_error }
    end

    context 'when token is invalid' do
      let(:handler) do
        Handler.new(code: 200,
                    response_body: not_registered_device_error_body.to_json,
                    receipt_ids: [],
                    error: true)
      end

      it { expect { push.send }.to raise_error(DeviceNotRegistered) }
    end

    context 'when another error is returned' do
      let(:handler) do
        Handler.new(code: 200,
                    response_body: invalid_credentials_error_body.to_json,
                    receipt_ids: [],
                    error: true)
      end

      it { expect { push.send }.to raise_error(StandardError) }
    end
  end

  describe '.verify_delivery' do
    let(:handler) do
      Handler.new(code: 200,
                  response_body: success_body.to_json,
                  receipt_ids: [receipt])
    end

    before do
      push.handler = handler
      allow(push.client).to receive(:verify_deliveries).with([receipt]) { verify_response }
    end

    context 'when token is valid' do
      let(:verify_response) do
        Handler.new(code: 200,
                    response_body: receipt_success_body.to_json,
                    receipt_ids: [receipt])
      end

      it { expect { push.verify_delivery }.not_to raise_error }
    end

    context 'when token is invalid' do
      let(:verify_response) do
        Handler.new(code: 200,
                    response_body: receipt_error_body.to_json,
                    receipt_ids: [receipt],
                    error: true)
      end

      it { expect { push.verify_delivery }.to raise_error(DeviceNotRegistered) }
    end

    context 'when another error is returned' do
      let(:verify_response) do
        Handler.new(code: 200,
                    response_body: receipt_another_error_body.to_json,
                    receipt_ids: [receipt],
                    error: true)
      end

      it { expect { push.verify_delivery }.to raise_error(StandardError) }
    end
  end
end

class Handler
  attr_reader :code, :response_body, :error, :receipt_ids

  def initialize(code:, response_body:, receipt_ids:, error: nil)
    @code = code
    @response_body = response_body
    @receipt_ids = receipt_ids
    @error = error || false
  end

  def response
    self
  end

  def errors?
    error
  end
end

def success_body
  { 'data' => [{ 'status' => 'ok' }] }
end

def receipt
  'YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY'
end

def receipt_success_body
  {
    'data' => {
      'YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY' => {
        'status' => 'ok'
      }
    }
  }
end

def receipt_error_body
  {
    'data' => {
      'YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY' => {
        'status' => 'error',
        'message' => 'The Apple Push Notification service failed to send the notification',
        'details' => {
          'error' => 'DeviceNotRegistered'
        }
      }
    }
  }
end

def receipt_another_error_body
  {
    'data' => {
      'YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY' => {
        'status' => 'error',
        'message' => 'The Apple Push Notification service failed to send the notification',
        'details' => {
          'error' => 'AnotherError'
        }
      }
    }
  }
end

def multiple_receipts
  {
    'data' => {
      'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX' => {
        'status' => 'error',
        'message' => 'The Apple Push Notification service failed to send the notification',
        'details' => {
          'error' => 'DeviceNotRegistered'
        }
      },
      'YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY' => {
        'status' => 'ok'
      }
    }
  }
end

def error_body
  {
    'errors' => [{
                   'code' => 'INTERNAL_SERVER_ERROR',
                   'message' => 'An unknown error occurred.'
                 }]
  }
end

def message_too_big_error_body
  build_error_body('MessageTooBig', 'Message too big')
end

def not_registered_device_error_body
  build_error_body(
    'DeviceNotRegistered',
    '"ExponentPushToken[42]" is not a registered push notification recipient'
  )
end

def message_rate_exceeded_error_body
  build_error_body('MessageRateExceeded', 'Message rate exceeded')
end

def invalid_credentials_error_body
  build_error_body('InvalidCredentials', 'Invalid credentials')
end

def apn_error_body
  {
    'data' => [{
                 'status' => 'error',
                 'message' =>
                   'Could not find APNs credentials for you (your_app). Check whether you are trying to send a notification to a detached app.'
               }]
  }
end

def client_args
  [
    'https://exp.host/--/api/v2/push/send',
    {
      body: messages.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      },
      accept_encoding: false
    }
  ]
end

def alternative_client_args(messages)
  [
    'https://exp.host/--/api/v2/push/send',
    {
      body: messages.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      },
      accept_encoding: false
    }
  ]
end

def gzip_client_args
  [
    'https://exp.host/--/api/v2/push/send',
    {
      body: messages.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      },
      accept_encoding: true
    }
  ]
end

def receipt_client_args(receipt_ids)
  [
    'https://exp.host/--/api/v2/push/getReceipts',
    {
      body: { ids: receipt_ids }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      },
      accept_encoding: false
    }
  ]
end

def gzip_receipt_client_args(receipt_ids)
  [
    'https://exp.host/--/api/v2/push/getReceipts',
    {
      body: { ids: receipt_ids }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      },
      accept_encoding: true
    }
  ]
end

def alternate_format_messages
  [{
     to: [
       'ExponentPushToken[xxxxxxxxxxxxxxxxxxxxxx]',
       'ExponentPushToken[yyyyyyyyyyyyyyyyyyyyyy]'
     ],
     badge: 1,
     sound: 'default',
     body: 'You got a completely unique message from us! /s'
   }]
end

def messages
  [{
     to: 'ExponentPushToken[xxxxxxxxxxxxxxxxxxxxxx]',
     sound: 'default',
     body: 'Hello world!'
   }, {
     to: 'ExponentPushToken[yyyyyyyyyyyyyyyyyyyyyy]',
     badge: 1,
     body: "You've got mail"
   }]
end

def too_many_messages
  (0..101).map { create_message }
end

def create_message
  id = (0...22).map { ('a'..'z').to_a[rand(26)] }.join
  {
    to: "ExponentPushToken[#{id}]",
    sound: 'default',
    body: 'Hello world!'
  }
end

def build_error_body(error_code, message)
  {
    'data' => [{
                 'status' => 'error',
                 'message' => message,
                 'details' => { 'error' => error_code }
               }]
  }
end
