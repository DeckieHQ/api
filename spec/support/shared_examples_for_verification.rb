RSpec.shared_examples 'fails to send verification for' do |attribute|
  it { expect(sent).to be_falsy }

  it "doesn't generate an #{attribute} verification token for the model" do
    expect(verification.model).to_not have_received(:"generate_#{attribute}_verification_token!")
  end

  it "doesn't send a message with verification instructions to the model #{attribute} " do
    expect(verification.model).to_not have_received(:"send_#{attribute}_verification_instructions")
  end
end

RSpec.shared_examples 'fails to complete verification for' do |attribute|
  it { expect(completed).to be_falsy }

  it "doesn't verify the model #{attribute}" do
    expect(verification.model).to_not have_received(:"verify_#{attribute}!")
  end
end

RSpec.shared_examples 'has inclusion error on verification type' do
  it 'has an inclusion error on type' do
    expect(verification.errors).to be_added(:type, :inclusion)
  end
end
