namespace :events do
  desc 'Update type to reflect previous boolean flexible on events'
  task :set_type => :environment do
    events = Event.where(flexible: true)

    puts "Going to update #{events.count} event"

    ActiveRecord::Base.transaction do
      events.with_deleted.each do |event|
        event.flexible!
        puts '.'
      end
    end
    puts ' All done now!'
  end
end
