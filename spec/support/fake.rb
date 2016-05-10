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
      %w(party board role-playing card dice video).sample
    end

    def ambiance
      %w(serious relaxed party).sample
    end

    def level
      %w(beginner intermediate advanced expert).sample
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
end
