class ImageFile
  def initialize(filename = nil, size = nil)
    set_filename(filename)
    set_size(size)
  end

  def set_filename(filename)
    @filename = if filename.is_a?(String)
                  filename
                end
  end

  def set_size(size)
    @size = if size.is_a?(Integer) && size >= 0
              size
            else
              0
            end
  end

  def original_filename
    @filename
  end

  attr_reader :size
end
