module EventSearch
  def self.included(base)
    base.class_eval do
      include AlgoliaSearch

      algoliasearch per_environment: true, enqueue: :index_worker, unless: :closed? do
        attributes :title,
                   :category,
                   :ambiance,
                   :level,
                   :capacity,
                   :auto_accept,
                   :description,
                   :begin_at,
                   :end_at,
                   :latitude,
                   :longitude,
                   :street,
                   :postcode,
                   :city,
                   :state,
                   :country,
                   :attendees_count

        attribute :full do
          full?
        end

        attribute :begin_at_i do
          begin_at.to_i
        end

        attribute :end_at_i do
          end_at.to_i
        end

        attributesToIndex [
          'unordered(title)',
          'unordered(state)',
          'unordered(city)',
          'unordered(country)',
          'unordered(description)'
        ]

        attributesForFaceting ['category', 'ambiance', 'level']

        customRanking ['asc(begin_at_i)', 'desc(attendees_count / capacity)']

        geoloc :latitude, :longitude
      end

      def self.index_worker(record, remove)
        RecordIndexJob.perform_later(record.id, record.class.name, remove)
      end
    end
  end
end
