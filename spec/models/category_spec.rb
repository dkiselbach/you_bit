require 'rails_helper'

RSpec.describe Category, type: :model do
  describe '.valid?' do
    context 'when name is missing' do
      it { expect(described_class.create(name: nil).errors.messages[:name][0]).to eq("can't be blank") }
    end

    context 'when name is a duplicate' do
      it 'validates uniqueness' do
        create(:category, name: 'running')
        expect(described_class.create(name: 'running').errors.messages[:name][0]).to eq('has already been taken')
      end
    end

    context 'when name is > 100 chars' do
      it 'validates length' do
        category = described_class.create(name: Faker::Alphanumeric.alpha(number: 101))
        expect(category.errors.messages[:name][0]).to eq('is too long (maximum is 100 characters)')
      end
    end
  end

  describe '.destroy' do
    context 'when Category has habits' do
      it 'marks habit categories as null' do
        habit = create(:habit)
        habit.category.destroy
        expect(habit.reload.category_id).to eq(nil)
      end
    end
  end
end


