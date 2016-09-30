class MultipleTimesValidator < ActiveModel::EachValidator
  def time_min
    @tile_min ||= Time.now + options[:after]
  end

  def validate_distinct_length(values)
    values.tap(&:uniq!).length >= options[:min] && values.length <= options[:max]
  end

  def validate_each(record, attribute, times)
    unless times.kind_of?(Array) && validate_distinct_length(times)
      return record.errors.add(attribute, :unsupported)
    end
    times.each do |time|
      unless time.respond_to?(:to_time) && time.to_time >= time_min
        return record.errors.add(attribute, :unsupported)
      end
    end
  end
end
