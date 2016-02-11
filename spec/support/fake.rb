module Fake
  module PhoneNumber
    extend self

    def plausible
      phone_number = "0#{rand(1..7)}#{rand(10000000..99999999)}"

      PhonyRails.normalize_number(phone_number, country_code: 'FR')
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
end
