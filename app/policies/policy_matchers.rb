module PolicyMatchers
  module Event
    def event_host?
      user.profile == event.host
    end

    def event_full?
      add_error(:event_full) if event.full?
    end

    def event_closed?
      add_error(:event_closed) if event.closed?
    end

    def event_flexible?
      add_error(:event_flexible) if event.flexible?
    end
  end

  module User
    def user_verified?
      !(add_error(:user_unverified) unless user.verified?)
    end
  end
end
