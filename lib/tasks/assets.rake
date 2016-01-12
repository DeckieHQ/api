# Heroku docker image automatically runs `rake assets:precompile` even if
# this task doesn't exist when using rails in api only mode. Therefore
# it is mandatory to have a dummy task to build the image.

namespace :assets do
  task :precompile do
    puts 'This is an API, skipping assets precompilation...'
  end
end
