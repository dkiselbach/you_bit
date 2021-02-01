# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PushNotificationJob, type: :job do
  include_context 'shared methods'
  let(:reminder) { create(:reminder, habit: user.habits.first) }
  let(:device) { create(:device, user: user) }
  let(:push) { instance_double(PushNotification) }

  describe '.perform' do
    context 'when reminder no longer exists' do
      it 'halts job' do
        invalid_reminder = reminder
        invalid_reminder.destroy
        expect { described_class.perform_now(invalid_reminder, device) }.not_to have_enqueued_job
      end
    end

    context 'when habit is no longer active' do
      it 'halts job' do
        invalid_reminder = reminder
        invalid_reminder.habit.active = false
        expect { described_class.perform_now(invalid_reminder, device) }.not_to have_enqueued_job
      end
    end

    context 'when device no longer exists' do
      it 'halts job' do
        invalid_device = device
        invalid_device.destroy
        expect { described_class.perform_now(reminder, invalid_device) }.not_to have_enqueued_job
      end
    end

    context 'when reminder exists' do
      before do
        allow(PushNotification).to receive(:new).and_return(push)
        allow(push).to receive(:send).and_return(push)
        # allow(PushNotification).to receive(:verify_delivery) { push }
      end

      it 'sends push notification' do
        described_class.perform_now(reminder, device)
        expect(push).to have_received(:send)
      end

      #it { expect(push).to have_received(:verify_delivery) }
    end
  end

  describe 'rescue_from :DeviceNotRegistered' do
    before do
      allow(PushNotification).to receive(:new).and_return(push)
      allow(push).to receive(:send).and_raise(DeviceNotRegistered)
    end

    context 'when token is invalid' do
      it 'invalid devise is removed' do
        device
        expect { described_class.perform_now(reminder, device) }.to change(Device, :count).by(-1)
      end
    end
  end

  describe 'rescue_from :ExpoPushNotificationError' do
    before do
      allow(PushNotification).to receive(:new).and_return(push)
      allow(push).to receive(:send).and_raise(ExpoPushNotificationError)
    end

    it 'last error message added to device' do
      described_class.perform_now(reminder, device)
      expect(JSON.parse(device.reload.last_error)['error_type']).to eq('ExpoPushNotificationError')
    end
  end
end
