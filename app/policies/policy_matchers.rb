module PolicyMatchers
  module Event
    def self.included(base)
      base.instance_eval do
        [:full, :closed, :flexible, :recurrent, :reached_time_slot_min].each do |state|
          define_method :"event_#{state}?" do
            add_error(:"event_#{state}") if event.public_send(:"#{state}?")
          end
        end
      end
    end

    def event_host?
      user.profile == event.host
    end
  end

  module User
    def user_verified?
      !(add_error(:user_unverified) unless user.verified?)
    end
  end
end
