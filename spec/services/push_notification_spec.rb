# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PushNotification do
  let(:args) do
    { token: 'ExponentPushToken[GCPOCHK-aKfYgHzwiL_AQO]', habit_name: 'Run everyday', body: 'Run everyday!',
      sound: 'default' }
  end
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

def not_registered_device_error_body
  build_error_body(
    'DeviceNotRegistered',
    '"ExponentPushToken[42]" is not a registered push notification recipient'
  )
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
