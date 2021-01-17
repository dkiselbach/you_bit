# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Device, type: :model do
  let(:user) { create(:user) }
  let(:args) { { token: Faker::Internet.uuid, platform: 'iOS', user: user } }

  describe 'valid?' do
    subject(:device_errors) { described_class.create(**args).errors.messages }

    context 'when token is not present' do
      it 'validates presence' do
        args[:token] = nil
        expect(device_errors[:token][0]).to eq("can't be blank")
      end
    end

    context 'when platform is not present' do
      it 'validates presence' do
        args[:platform] = nil
        expect(device_errors[:platform][0]).to eq("can't be blank")
      end
    end

    context 'when platform is invalid' do
      it 'validates presence' do
        args[:platform] = 'Windows Phone'
        expect(device_errors[:platform][0]).to eq('is not included in the list')
      end
    end
  end
end
