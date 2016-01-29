require 'set'

RSpec.shared_examples 'fails to send verification for' do |attribute|
  it 'returns false' do
    expect(verification.send_instructions).to be_falsy
  end

  it "doesn't generate an #{attribute} verification token for the model" do
    expect(verification.model).to_not receive(:"generate_#{attribute}_verification_token!")

    verification.send_instructions
  end

  it "doesn't send an #{attribute} with verification instructions to the model" do
    expect(verification.model).to_not receive(:"send_#{attribute}_verification_instructions")

    verification.send_instructions
  end

  it 'has errors' do
    expect { verification.send_instructions }.to change { verification.errors.count }
  end
end

RSpec.shared_examples 'fails to complete verification for' do |attribute|
  it 'returns false' do
    expect(verification.complete).to be_falsy
  end

  it "doesn't verify the model #{attribute}" do
    expect(verification.model).to_not receive(:"verify_#{attribute}!")

    verification.complete
  end

  it 'has errors' do
    expect { verification.complete }.to change { verification.errors.count }
  end
end
