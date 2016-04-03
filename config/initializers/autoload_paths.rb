['services/concerns', 'services', 'smsers', 'utils'].each do |dir|
  Dir[File.join(Rails.root, 'app', dir, '**', '*.rb')].each { |path| require path }
end
