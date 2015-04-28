require "opencv"

def progress_bar(i, max = 100)
  i = i.to_f
  max = max.to_f
  i = max if i > max
  percent = i / max * 100.0
  rest_size = 1 + 5 + 1 # space + progress_num + %
  bar_size = 79 - rest_size # (width - 1) - rest_size
  bar_str = '%-*s' % [bar_size, ('#' * (percent * bar_size / 100).to_i)]
  progress_num = '%3.1f' % percent
  print "\r#{bar_str} #{'%5s' % progress_num}%"
end

class OpenCV::CvMat
  def calculate_degree_of_diff(same_size_image)
    a = self
    b = same_size_image
    c = a.abs_diff b
    ########################################
    # 緑単色
    ########################################
    green = c.split[1]
    # blue, green, red, * = c.split
    multipled = green.mul green
    error = multipled.sum.to_ary[0]
    ########################################
    # 全色
    ########################################
    # error = c.split.inject(0) do |sum, c_parsed|
    #   multipled = c_parsed.mul c_parsed
    #   sum + multipled.sum.to_ary[0]
    # end

    return error
  end

  def calculate_MSE(same_size_image)
    a = self
    b = same_size_image
    c = a.abs_diff b

    mse = c.split.inject(0) do |sum, c_parsed|
      multipled = c_parsed.mul c_parsed # dr ^2 or dg ^ 2 or db ^ 2
      sum + multipled.sum.to_ary[0] # 和を取る。
    end

    mse /= 3 * a.width * a.height
  end

  def rgb(x, y)
    blue, green, red = self.at(y - 1, x - 1).to_a
    return {
      green: green,
      red: red,
      blue: blue,
    }
  end

  def griddable?(config)
    pertition = config[:pertition]
    a = self
    if pertition[:regular_square]
      px = pertition[:square_px].to_i
      return a.dividable?(px, px)
    end
    return a.dividable?(pertition[:width], pertition[:height])

  end

  def dividable?(width, height)
    a = self
    unless a.width % width == 0 and a.height % height == 0
      p "grid number ... ng"
      p "a.width is #{a.width}, but dividing number is #{width}"
      p "a.height is #{a.height}, but dividing number is #{height}"
      return false
    end
    p "grid number ... ok"
    return true
  end

  def gridize(config)
    pertition = config[:pertition]
    px = pertition[:square_px].to_i
    a = self
    if pertition[:regular_square]
      per_width = px
      per_height = px
      num_w = a.width / px
      num_h = a.height / px
    else
      num_w = pertition[:width].to_i
      num_h = pertition[:height].to_i
      per_width = a.width / num_w
      per_height = a.height / num_h
    end

    results = []
    (0...(num_w)).each do |x|
      (0...(num_h)).each do |y|
        pos_x = x * per_width
        pos_y = y * per_height
        mat = a.sub_rect pos_x, pos_y, per_width, per_height
        result = {
          x: pos_x,
          y: pos_y,
          mat: mat
        }
        results.push result
      end
    end
    return results
  end

  def has_identical_size?(image)
    a = self
    d = image

    if a.width == d.width and a.height == d.height
      return true
    else
      p "a 画像と同じ大きさの d 画像を指定してください。"
      return false
    end
  end

  def idealize(config)
    pertition = config[:pertition]

    num_w = pertition[:width].to_i
    num_h = pertition[:height].to_i
    if pertition[:regular_square]
      px = pertition[:square_px]
      num_w = px
      num_h = px
    end

    error_w = self.width % num_w
    error_h = self.height % num_h

    p "idealize width -#{error_w}"
    p "idealize height -#{error_h}"

    filling = config[:idealization_config]
    if filling[:right_fill]
      x = error_w
      len_x = self.width - error_w
    else
      x = 0
      len_x = self.width - error_w
    end

    if filling[:bottom_fill]
      y = error_h
      len_y = self.height - error_h
    else
      y = 0
      len_y = self.height - error_h
    end

    self.sub_rect x, y, len_x, len_y

  end

  def placesAt(bigImage)
    a = self
    b = bigImage

    search_width = b.width - a.width + 1
    search_height = b.height - a.height + 1
    num_try = (search_height) * (search_width)
    sub_rect_width = a.width
    sub_rect_height = a.height

    results = []
    counts = 0
    (0...search_width).each do |x|
      (0...search_height).each do |y|
        target = b.sub_rect x, y, sub_rect_width, sub_rect_height
        diff = a.calculate_degree_of_diff target
        result = {
          x: x,
          y: y,
          diff: diff
        }
        results.push result
        counts += 1
        progress_bar counts, num_try
      end
    end
    print "\n"
    results.min_by do |result|
      result[:diff]
    end
  end

  def smaller_than?(image)
    a = self
    b = image

    return false unless a.valid? or b.valid?
    if a.height < b.height and a.width < b.width
      return true
    else
      return false
    end
  end

  def valid?
    a = self
    if a.height * a.width > 0
      return true
    else
      return false
    end
  end
end
