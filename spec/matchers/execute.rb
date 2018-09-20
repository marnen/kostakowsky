RSpec::Matchers.define :execute do |*params|
  match do |receiver|
    expect(receiver).to receive(:shell).with(*params)
  end

  description { %Q{execute "#{params.join ' '}"} }
end
