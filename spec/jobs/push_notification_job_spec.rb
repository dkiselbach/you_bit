# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PushNotificationJob, type: :job do
  include_context 'shared methods'
  let(:reminder) { create(:reminder, habit: user.habits.first) }
  let(:device) { create(:device, user: user) }
  let(:push) { instance_double(PushNotification) }

  describe '.perform' do
    before do
      allow(PushNotification).to receive(:new).and_return(push)
      allow(push).to receive(:send).and_return(push)
      # allow(PushNotification).to receive(:verify_delivery) { push }
    end

    context 'when reminder no longer exists' do
      it 'halts job' do
        reminder.destroy
        described_class.perform_now(reminder, device)
        expect(push).not_to have_received(:send)
      end
    end

    context 'when habit is no longer active' do
      it 'halts job' do
        reminder.habit.update(active: false)
        described_class.perform_now(reminder, device)
        expect(push).not_to have_received(:send)
      end
    end

    context 'when habit is already logged' do
      it 'halts job' do
        create(:habit_log, habit: reminder.habit, logged_date: Date.current)
        described_class.perform_now(reminder, device)
        expect(push).not_to have_received(:send)
      end
    end

    context 'when device no longer exists' do
      it 'halts job' do
        device.destroy
        described_class.perform_now(reminder, device)
        expect(push).not_to have_received(:send)
      end
    end

    context 'when reminder exists' do
      it 'sends push notification' do
        described_class.perform_now(reminder, device)
        expect(push).to have_received(:send)
      end

      # it { expect(push).to have_received(:verify_delivery) }
    end
  end

  describe 'rescue_from :DeviceNotRegistered' do
    before do
      allow(PushNotification).to receive(:new).and_return(push)
      allow(push).to receive(:send).and_raise(DeviceNotRegistered)
    end

    context 'when token is invalid' do
      it 'invalid device is removed' do
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
