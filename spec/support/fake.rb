module Fake
  module Preferences
    extend self

    def notifications
      values = ::Notification.types

      # Injecting duplicates voluntarily in order to have more randomness.
      (values.length / 2).times.inject([]) do |result|
        result.push(values.shuffle.first)
      end.uniq
    end
  end

  module PhoneNumber
    extend self

    def plausible
      phone_number = "0#{rand(1..7)}#{rand(10000000..99999999)}"

      PhonyRails.normalize_number(phone_number, country_code: 'FR')
    end
  end

  module User
    extend self

    def culture
      %w(en fr).sample
    end
  end

  module Event
    extend self

    def category
      %w(
        board role-playing card deck-building dice miniature video outdoor
        strategy cooperative ambiance playful tile-based, other
      ).sample
    end

    def ambiance
      %w(relaxed serious teasing).sample
    end

    def level
      %w(beginner intermediate advanced).sample
    end

    def time_slots
      Array.new(5).map do
        TimeSlot.begin_at
      end
    end
  end

  module TimeSlot
    extend self

    def begin_at
      Faker::Time.between(Time.now + 1.day, Time.now + 10.day, :all)
    end
  end

  module Submission
    extend self

    def status
      [:pending, :confirmed].sample
    end
  end

  module Action
    extend self

    def type_for(resource_type, direct: false)
      return 'join' if direct && resource_type == 'Event'

      prefix = "#{resource_type.downcase}-"

      ::Notification.types.select do |notification_type|
        notification_type.start_with?(prefix)
      end.map do |notification_type|
        notification_type.gsub(prefix, '')
      end.sample
    end
  end

  module Notification
    extend self

    def viewed
      [true, false].sample
    end
  end

  module File
    extend self

    def pdf
      "data:application/pdf;base64,/9j/4AAQSkZJRgABAQEASABKdhH//2Q=="
    end
  end
end
