%w(mailers/contents services/concerns services smsers utils policies/scopes).each do |dir|
  Dir[File.join(Rails.root, 'app', dir, '**', '*.rb')].each { |path| require path }
end
