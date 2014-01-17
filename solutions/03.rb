module Graphics
  class Renderers
    class Ascii
      def self.render(canvas)
        pixels = Array.new(canvas.width * canvas.height, "-")
        canvas.full_pixels.each { |x, y| pixels[y * canvas.width + x] = "@" }
        output = ""
        pixels.each_slice(canvas.width) { |row| output << row.join("") << "\n" }
        output.chomp("\n")
      end
    end

    class Html
      BEGINNING = <<-HTML_BEGINNING
                    <!DOCTYPE html>
                    <html>
                    <head>
                      <title>Rendered Canvas</title>
                      <style type="text/css">
                        .canvas {
                          font-size: 1px;
                          line-height: 1px;
                        }
                        .canvas * {
                          display: inline-block;
                          width: 10px;
                          height: 10px;
                          border-radius: 5px;
                        }
                        .canvas i {
                          background-color: #eee;
                        }
                        .canvas b {
                          background-color: #333;
                        }
                      </style>
                    </head>
                    <body>
                      <div class="canvas">
                  HTML_BEGINNING

      ENDING = <<-HTML_ENDING
                   </div>
                 </body>
                 </html>
               HTML_ENDING

      def self.render(canvas)
        pixels = Array.new(canvas.width * canvas.height, "<i></i>")
        canvas.full_pixels.each { |x, y| pixels[y * canvas.width + x] = "<b></b>" }
        output = ""
        pixels.each_slice(canvas.width) { |row| output << row.join("") << "<br>" }
        [BEGINNING, output.chomp("<br>"), ENDING].join("")
      end
    end
  end

  class Canvas
    attr_reader :width, :height, :full_pixels

    def initialize(width, height)
      @width = width
      @height = height
      @full_pixels = []
    end

    def set_pixel(x, y)
      if x.between?(0, width.pred) and y.between?(0, height.pred)
        @full_pixels << [x, y]
      end
    end

    def pixel_at?(x, y)
      @full_pixels.include? [x, y]
    end

    def draw(figure)
      @full_pixels += figure.rasterize
    end

    def render_as(renderer)
      renderer.render self
    end
  end

  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def coordinates
      [@x, @y]
    end

    def rasterize
      [coordinates]
    end

    def hash
      [@x, @y].hash
    end

    def ==(other)
      @x == other.x and @y == other.y
    end

    alias_method :eql?, :==
  end

  class Bresenham
    def initialize(line)
      @x, @y, @end_x, @end_y = *line.from.coordinates, *line.to.coordinates
      @pixels, @swap = [], false
      @delta_x, @delta_y = (@end_x - @x).abs, (@end_y - @y).abs
      @signum_x, @signum_y = @end_x <=> @x, @end_y <=> @y
    end

    def swap
      if @delta_x < @delta_y
        @delta_x, @delta_y = @delta_y, @delta_x
        @swap = true
      end
      @error = 2 * @delta_y - @delta_x
    end

    def next_pixel
      if @error > 0
        @swap ? @x += @signum_x : @y += @signum_y
        @error -= 2 * @delta_x
      end
      @swap ? @y += @signum_y : @x += @signum_x
      @error += 2 * @delta_y
    end

    def rasterize
      swap
      @delta_x.times do
        @pixels << [@x, @y]
        next_pixel
      end
      @pixels << [@end_x, @end_y]
    end
  end

  class Line
    def initialize(from, to)
      @from = from
      @to = to
    end

    def from
      if @from.x == @to.x
        @from.y < @to.y ? @from : @to
      else
        @from.x < @to.x ? @from : @to
      end
    end

    def to
      if @from.x == @to.x
        @from.y < @to.y ? @to : @from
      else
        @from.x < @to.x ? @to : @from
      end
    end

    def hash
      [from.hash, to.hash].hash
    end

    def ==(other)
      from == other.from and to == other.to
    end

    alias_method :eql?, :==

    def rasterize
      bresenham = Bresenham.new self
      bresenham.rasterize
    end
  end

  class Rectangle
    attr_reader :left, :right, :top_left

    def initialize(left, right)
      @left = Line.new(left, right).from
      @right = Line.new(left, right).to
      @top_left = Point.new([left.x, right.x].min, [left.y, right.y].min)
      @width = (left.x - right.x).abs
      @height = (left.y - right.y).abs
    end

    def hash
      [top_left.hash, bottom_right.hash].hash
    end

    def ==(other)
      top_left == other.top_left and bottom_right == other.bottom_right
    end

    alias_method :eql?, :==

    def top_right
      Point.new @top_left.x + @width, @top_left.y
    end

    def bottom_left
      Point.new @top_left.x, @top_left.y + @height
    end

    def bottom_right
      Point.new @top_left.x + @width, @top_left.y + @height
    end

    def border
        lines = Line.new(top_left, top_right).rasterize
        lines += Line.new(top_left, bottom_left).rasterize
        lines += Line.new(bottom_left, bottom_right).rasterize
        lines += Line.new(bottom_right, top_right).rasterize
    end

    def rasterize
      if left == right
        left.rasterize
      elsif left.x == right.x or left.y == right.y
        Line.new(left, right).rasterize
      else
        border
      end
    end
  end
end