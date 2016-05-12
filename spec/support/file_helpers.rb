require 'base64'

module FileHelpers
  module Image
    def image_param(filename)
      "data:image/jpeg;base64,#{encoded_image(filename)}"
    end

    def encoded_image(filename)
      Base64.encode64(read_image(filename))
    end

    def read_image(filename)
      open_image(filename).read
    end

    def open_image(filename)
      File.open(Rails.root.join("spec/support/images/#{filename}"))
    end
  end
end
