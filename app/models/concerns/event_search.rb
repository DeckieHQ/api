module EventSearch
  def self.included(base)
    base.class_eval do
      include AlgoliaSearch

      algoliasearch per_environment: true, unless: :closed? do
        attribute :title,
                  :category,
                  :ambiance,
                  :level,
                  :capacity,
                  :auto_accept,
                  :description,
                  :begin_at,
                  :end_at,
                  :street,
                  :postcode,
                  :city,
                  :state,
                  :country,
                  :attendees_count

        attribute :begin_at_i do
          begin_at.to_i
        end

        attribute :end_at_i do
          end_at.to_i
        end

        attributesToIndex ['unordered(title)', 'unordered(description)']

        customRanking ['desc(attendees_count)']

        geoloc :latitude, :longitude
      end
    end
  end
end
