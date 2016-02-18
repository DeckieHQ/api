RSpec.shared_examples 'acts as verifiable' do |attribute, options|
  factory               = described_class.name.downcase

  generate_token        = :"generate_#{attribute}_verification_token!"
  verify                = :"verify_#{attribute}!"
  verified              = :"#{attribute}_verified?"
  send_instructions     = :"send_#{attribute}_verification_instructions"

  verification_token    = "#{attribute}_verification_token"
  verification_sent_at  = "#{attribute}_verification_sent_at"
  verified_at           = "#{attribute}_verified_at"

  context "when created" do
    subject(:model) { FactoryGirl.create(factory) }

    it 'has an unverified email' do
      expect(model).to have_unverified attribute
    end
  end

  context "when updating the #{attribute}" do
    before do
      model.update(attribute => options[:faker].call)
    end

    context "when #{attribute} is already verified" do
      subject(:model) { FactoryGirl.create(:"#{factory}_with_#{attribute}_verified") }

      include_examples 'reset the verification', attribute
    end

    context "when #{attribute} is waiting for verification" do
      subject(:model) { FactoryGirl.create(:"#{factory}_with_#{attribute}_verification") }

      include_examples 'reset the verification', attribute
    end
  end

  context 'when updating another attribute' do
    subject(:model) { FactoryGirl.create(:"#{factory}_with_#{attribute}_verification") }

    before do
      @previous_attributes = model.attributes.except('created_at', 'updated_at')

      model.update(created_at: Time.now)
    end

    it "doesn't reset the #{attribute} verification" do
      expect(model).to have_attributes(@previous_attributes)
    end
  end

  describe "##{generate_token}" do
    subject(:model) { FactoryGirl.create(factory) }

    before do
      model.tap(&generate_token).reload
    end

    it "creates a #{attribute} verification token" do
      token_type = options[:token_type]

      expect(model.send(verification_token)).to be_valid_token(token_type)
    end

    it "set :#{verification_sent_at} to current datetime" do
      expect(model.send(verification_sent_at)).to equal_time(Time.now)
    end
  end

  describe "##{verify}" do
    subject(:model) { FactoryGirl.create(:"#{factory}_with_#{attribute}_verification") }

    before do
      model.tap(&verify).reload
    end

    it "removes the #{attribute} verification token" do
      expect(model.send(verification_token)).to be_nil
    end

    it "set :#{verified_at} to current datetime" do
      expect(model.send(verified_at)).to equal_time(Time.now)
    end
  end

  describe "##{verified}?" do
    context "when #{attribute} is verified" do
      subject(:model) { FactoryGirl.create(:"#{factory}_with_#{attribute}_verified") }

      it { expect(model.send(verified)).to be_truthy }
    end

    context "when #{attribute} is not verified" do
      subject(:model) { FactoryGirl.create(factory) }

      it 'returns false' do
        expect(model.send(verified)).to be_falsy
      end
    end
  end

  describe "##{send_instructions}" do
    subject(:model) { FactoryGirl.create(:"#{factory}_with_#{attribute}_verification") }

    before do
      @deliveries = options[:deliveries]

      @deliveries.use_fake_provider if @deliveries.respond_to?(:use_fake_provider)
    end

    after do
      @deliveries.clear
    end

    it "sends a message to the #{attribute} with verification instructions" do
      deliveries = options[:deliveries]

      expect { model.send(send_instructions) }.to change { deliveries.count }.by 1
    end
  end
end

RSpec.shared_examples 'reset the verification' do |attribute|
  it do
    expect(model).to have_unverified attribute
  end
end
