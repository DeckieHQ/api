['services', 'smsers', 'utils', 'jobs/notifiers'].each do |dir|
  Dir[File.join(Rails.root, 'app', dir, '**', '*.rb')].each { |path| require path }
end
