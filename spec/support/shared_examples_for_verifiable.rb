require 'set'

RSpec.shared_examples 'acts as verifiable for' do |attribute, options|
  GENERATE_TOKEN        = :"generate_#{attribute}_verification_token!"
  VERIFY                = :"verify_#{attribute}!"
  SEND_INSTRUCTIONS     = :"send_#{attribute}_verification_instructions"

  VERIFICATION_TOKEN    = "#{attribute}_verification_token"
  VERIFICATION_SENT_AT  = "#{attribute}_verification_sent_at"
  VERIFIED_AT           = "#{attribute}_verified_at"

  context "when created" do
    subject(:model) { FactoryGirl.create(:user) }

    it 'has an unverified email' do
      expect(model).to have_unverified attribute
    end
  end

  context "when updating the #{attribute}" do
    before do
      model.update({ :"#{attribute}" => 'updating.email@yopmail.com' })
    end

    context "when #{attribute} is already verified" do
      subject(:model) { FactoryGirl.create(:user).tap(&VERIFY) }

      it "reset the #{attribute} verification" do
        expect(model).to have_unverified attribute
      end
    end

    context "when #{attribute} is waiting for verification" do
      subject(:model) { FactoryGirl.create(:user).tap(&GENERATE_TOKEN) }

      it "reset the #{attribute} verification" do
        expect(model).to have_unverified attribute
      end
    end
  end

  context 'when updating another attribute' do
    subject(:model) { FactoryGirl.create(:user).tap(&GENERATE_TOKEN) }

    before do
      @previous_attributes = model.attributes.except('created_at', 'updated_at')

      model.update(created_at: Time.now)
    end

    it "doesn't reset the #{attribute} verification" do
      expect(model).to have_attributes(@previous_attributes)
    end
  end

  describe "##{GENERATE_TOKEN}" do
    subject(:model) { FactoryGirl.create(:user) }

    before do
      model.tap(&GENERATE_TOKEN).reload
    end

    it "creates an #{attribute} verification token" do
      expect(model.send(VERIFICATION_TOKEN)).to be_present
    end

    it "set :#{VERIFICATION_SENT_AT} to current datetime" do
      expect(model.send(VERIFICATION_SENT_AT)).to equal_time(Time.now)
    end
  end

  describe "##{VERIFY}" do
    subject(:model) { FactoryGirl.create(:user).tap(&GENERATE_TOKEN) }

    before do
      model.tap(&VERIFY).reload
    end

    it "removes the #{attribute} verification token" do
      expect(model.send(VERIFICATION_TOKEN)).to be_nil
    end

    it "set :#{VERIFIED_AT} to current datetime" do
      expect(model.send(VERIFIED_AT)).to equal_time(Time.now)
    end
  end

  describe "##{SEND_INSTRUCTIONS}" do
    subject(:model) { FactoryGirl.create(:user).tap(&GENERATE_TOKEN) }

    it "sends a message to the #{attribute} with verification instructions" do
      deliveries = options[:deliveries]

      expect { model.send(SEND_INSTRUCTIONS) }.to change { deliveries.count }.by 1
    end
  end
end
