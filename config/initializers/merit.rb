Merit::Badge.class_eval do
  self.include ActiveModel::Serialization
end

Merit.setup do |config|
  # Check rules on each request or in background
  # config.checks_on_each_request = true

  # Define ORM. Could be :active_record (default) and :mongoid
  config.orm = :active_record

  # Add application observers to get notifications when reputation changes.
  # config.add_observer 'MyObserverClassName'

  # Define :user_model_name. This model will be used to grand badge if no
  # `:to` option is given. Default is 'User'.
  # config.user_model_name = 'User'

  # Define :current_user_method. Similar to previous option. It will be used
  # to retrieve :user_model_name object if no `:to` option is given. Default
  # is "current_#{user_model_name.downcase}".
  # config.current_user_method = 'current_user'
end

# Create application badges (uses https://github.com/norman/ambry)
badge_id = 0
[{
  id: (badge_id = badge_id+1),
  name: 'early-registration',
  description: 'Registered before launch.'
}, {
  id: (badge_id = badge_id+1),
  name: 'first-feedback',
  description: 'Created a first feedback report.'
}, {
  id: (badge_id = badge_id+1),
  name: 'early-event',
  description: 'Created an event before launch.'
}, {
  id: (badge_id = badge_id+1),
  name: 'verified-profile',
  description: 'Verified email and phone number.'
}, {
  id: (badge_id = badge_id+1),
  name: 'first-invitation',
  description: 'Created a first invitation.'
}, {
  id: (badge_id = badge_id+1),
  name: 'first-flexible-event',
  description: 'Created a first flexible event.'
}, {
  id: (badge_id = badge_id+1),
  name: 'first-unlimited-event-capacity',
  description: 'Created a first event with unlimited capacity.'
}, {
  id: (badge_id = badge_id+1),
  name: 'first-recurrent-event',
  description: 'Created a first recurrent event.'
}].each do |attrs|
  Merit::Badge.create!(attrs)
end
