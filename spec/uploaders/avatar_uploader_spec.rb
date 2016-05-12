require 'rails_helper'

RSpec.describe AvatarUploader, :type => :uploader do
  include CarrierWave::Test::Matchers

  let(:profile) { FactoryGirl.create(:profile) }

  let(:uploader) { described_class.new(profile, :avatar) }

  before do
    described_class.enable_processing = true
  end

  after do
    described_class.enable_processing = false
  end

  [:jpeg, :jpg].each do |type|
    context "when image type is #{type}" do
      before do
        open_image("avatar.#{type}") do |image|
          uploader.store!(image)
        end
      end

      after  { uploader.remove! }

      it 'has the correct format' do
        expect(uploader.format).to eq('jpg')
      end
    end
  end

  context 'when image size is invalid' do
    it 'raises an integrity error' do
      open_image('avatar_too_big.jpg') do |image|
        expect { uploader.store!(image) }.to raise_error(CarrierWave::IntegrityError)
      end
    end
  end

  context 'when image type is invalid' do
    it 'raises an integrity error' do
      File.open(Rails.root.join('Gemfile')) do |file|
        expect { uploader.store!(file) }.to raise_error(CarrierWave::IntegrityError)
      end
    end
  end
end
