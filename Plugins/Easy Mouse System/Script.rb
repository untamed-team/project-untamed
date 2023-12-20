#===============================================================================
#  Easy Mouse System
#   by Luka S.J
#
#  Adds easy to use mouse functionality for your Essentials code
#===============================================================================
module Mouse
  #  amount of time needed to pass (in seconds) for the mouse to be considered
  #  inactive
  #  negative value means the mouse is always active
  INACTIVITY_TIMER = -1

  # amount of time needed to pass (in seconds) before the release of a mouse click
  # until that click is considered invalid
  CLICK_TIMEOUT = 0.5

  class << self
    #---------------------------------------------------------------------------
    #  sets up mouse variables initially
    #---------------------------------------------------------------------------
    def start
      @static_x = 0
      @static_y = 0
      @inactivity_timer = 0
      @input_map = {
        left: Input::MOUSELEFT,
        right: Input::MOUSERIGHT,
        middle: Input::MOUSEMIDDLE
      }
      @hold = 0
      @drag = nil
      @object_x = 0
      @object_y = 0
      @object_ox = 0
      @object_oy = 0
      @rect_x = nil
      @rect_y = nil
    end
    #---------------------------------------------------------------------------
    #  safe input map function
    #---------------------------------------------------------------------------
    def input_map(button)
      @input_map[button] || Input::MOUSELEFT
    end
    #---------------------------------------------------------------------------
    #  returns current mouse X position
    #---------------------------------------------------------------------------
    def x
      @x || 0
    end
    #---------------------------------------------------------------------------
    #  returns current mouse Y position
    #---------------------------------------------------------------------------
    def y
      @y || 0
    end
    #---------------------------------------------------------------------------
    #  updates required mouse variables
    #---------------------------------------------------------------------------
    def update
      @x, @y = getMousePos
      if INACTIVITY_TIMER >= 0 && !static?
        @inactivity_timer += 1
      else
        @inactivity_timer = 0
      end
    end
    #---------------------------------------------------------------------------
    #  checks if mouse is not moving
    #---------------------------------------------------------------------------
    def static?
      unless @static_x.eql?(@x) && @static_y.eql(@y)
        @static_x = @x
        @static_y = @y
        return false
      end

      true
    end
    #---------------------------------------------------------------------------
    #  checks if mouse input is currently active
    #---------------------------------------------------------------------------
    def active?
      return true if INACTIVITY_TIMER.negative?

      return false if @inactive_timer > INACTIVITY_TIMER * Graphics.frame_rate

      true
    end
    #---------------------------------------------------------------------------
    #  analyzes given object and returns valid coordinates from it
    #---------------------------------------------------------------------------
    def object_params(object = nil)
      return 0, 0, 0, 0 unless object

      return object.rect.x, object.rect.y, object.rect.width, object.rect.height if object.is_a?(Viewport)

      ox, oy, ow, oh = 0, 0, 0, 0

      ox = object.x - (object.respond_to?(:ox) ? object.ox : 0) if object.respond_to?(:x)
      oy = object.y - (object.respond_to?(:oy) ? object.oy : 0) if object.respond_to?(:y)

      if object.respond_to?(:bitmap) && object.bitmap.is_a?(Bitmap)
        ow = object.bitmap.width * (object.respond_to?(:zoom_x) ? object.zoom_x : 1)
        oh = object.bitmap.height * (object.respond_to?(:zoom_y) ? object.zoom_y : 1)
      else
        ow = object.width * (object.respond_to?(:zoom_x) ? object.zoom_x : 1) if object.respond_to?(:width)
        oh = object.height * (object.respond_to?(:zoom_y) ? object.zoom_y : 1) if object.respond_to?(:height)
      end

      if object.respond_to?(:src_rect) && object.src_rect.is_a?(Rect)
        ow = object.src_rect.width * (object.respond_to?(:zoom_x) ? object.zoom_x : 1) if !object.src_rect.width.eql?(ow)
        oh = object.src_rect.height * (object.respond_to?(:zoom_y) ? object.zoom_y : 1) if !object.src_rect.height.eql?(oh)
      end

      if object.respond_to?(:viewport) && object.viewport.is_a?(Viewport)
        ox += object.viewport.rect.x
        oy += object.viewport.rect.y
      end

      return ox, oy, ow, oh
    end
    #---------------------------------------------------------------------------
    #  checks if object is being dragged with mouse
    #---------------------------------------------------------------------------
    def dragging?(object, button = :left)
      unless press?(object, button) || (Input.press?(input_map(button)) && @drag.eql?(object))
        @drag = nil
        @object_ox = 0
        @object_oy = 0
        return false
      end

      @drag = [x, y] if @drag.nil?
      if @drag.is_a?(Array) && (!@drag[0].eql?(x) || !@drag[1].eql?(y))
        @drag = object
        @object_ox = x - object.x
        @object_oy = y - object.y
      end

      true
    end
    #---------------------------------------------------------------------------
    #  method to drag object using mouse
    #    - `lock` argument decides which axis to lock the dragging on
    #    - `rect` parameter creates a maximum dragging area
    #---------------------------------------------------------------------------
    def drag_object(object, button = :left, rect = nil, lock = nil)
      return false unless dragging?(object, button) && @drag.eql?(object)

      object.x = x - @object_ox if !lock.eql?(:vertical)
      object.y = y - @object_oy if !lock.eql?(:horizontal)
      if rect.is_a?(Rect)
        rx, ry, rw, rh = object_params(rect)
        _ox, _oy, ow, oh = object_params(object)
        object.x = rx if object.x < rx && !lock.eql?(:vertical)
        object.y = ry if object.y < ry && !lock.eql?(:horizontal)
        object.x = rx + rw - ow if object.x > rx + rw - ow && !lock.eql?(:vertical)
        object.y = ry + rh - oh if object.y > ry + rh - oh && !lock.eql?(:horizontal)
      end
    end
    #---------------------------------------------------------------------------
    #  method to drag object only on the X axis
    #---------------------------------------------------------------------------
    def drag_object_x(object, button = :left, rect = nil)
      drag_object(object, button, rect, :horizontal)
    end
    #---------------------------------------------------------------------------
    #  method to drag object only on the Y axis
    #---------------------------------------------------------------------------
    def drag_object_y(object, button = :left, rect = nil)
      drag_object(object, button, rect, :vertical)
    end
    #---------------------------------------------------------------------------
    #  method to create a rectangle based on mouse click and drag
    #---------------------------------------------------------------------------
    def create_rect(button = :left, object = nil)
      return Rect.new(0, 0, 0, 0) if object && !over?(object) && Input.press?(input_map(button)) && @rect_x.nil?

      if Input.press?(input_map(button))
        @rect_x = x if @rect_x.nil?
        @rect_y = y if @rect_y.nil?
        rx = x < @rect_x ? x : @rect_x
        ry = y < @rect_y ? y : @rect_y
        rw = x < @rect_x ? @rect_x - x : x - @rect_x
        rh = y < @rect_y ? @rect_y - y : y - @rect_y
        if object
          ox, oy, ow, oh = object_params(object)
          rx -= ox
          ry -= oy
        end
        return Rect.new(rx, ry, rw, rh)
      end

      @rect_x = nil
      @rect_y = nil
      Rect.new(0, 0, 0, 0)
    end
    #---------------------------------------------------------------------------
    #  end user specific functions
    #---------------------------------------------------------------------------
    #  checks if mouse is currently hovering over an object with valid
    #  coordinate functionality
    #  can pass an additional `Rect.new` argument to offset the observed area
    #---------------------------------------------------------------------------
    def over?(object, rect = nil)
      return false unless active? && object

      ox, oy, ow, oh = object_params(object)

      if rect.is_a?(Rect)
        ox += rect.x
        oy += rect.y
        ow -= rect.width - rect.x
        oh -= rect.height - rect.y
      end

      x.between?(ox, ox + ow) && y.between?(oy, oy + oh)
    end
    #---------------------------------------------------------------------------
    #  checks if mouse is hovering over sprite pixel
    #---------------------------------------------------------------------------
    def over_pixel?(object)
      return over?(object) unless object.is_a?(Sprite) && object.bitmap.is_a?(Bitmap)

      return false unless over?(object)

      ox, oy, _ow, _oh = object_params(object)

      mx = x - ox
      my = y - oy

      object.bitmap.get_pixel(mx, my).alpha.positive?
    end
    #---------------------------------------------------------------------------
    #  checks if mouse is over specific area of the game window
    #---------------------------------------------------------------------------
    def over_area?(arx, ary, arw, arh)
      over?(Rect.new(arx, ary, arw, arh))
    end
    #---------------------------------------------------------------------------
    #  check if mouse is being pressed and held down for a specific period of time
    #---------------------------------------------------------------------------
    def hold?(object = nil, button = :left)
      return false unless press?(object, button)

      Input.time?(input_map(button)) > CLICK_TIMEOUT * 1000000
    end
    #---------------------------------------------------------------------------
    #  check if mouse is pressing on object
    #---------------------------------------------------------------------------
    def press?(object = nil, button = :left)
      return false if object && !over?(object)

      Input.press?(input_map(button))
    end
    #---------------------------------------------------------------------------
    #  check if mouse is clicking on object
    #---------------------------------------------------------------------------
    def click?(object = nil, button = :left)
      return false if object && !over?(object)

      return @hold = 0 || true if !Input.press?(input_map(button)) && @hold.between?(1, CLICK_TIMEOUT * 1000000)

      @hold = Input.time?(input_map(button))
      false
    end
    #---------------------------------------------------------------------------
  end
end
#===============================================================================
#  Input module override for mouse update
#===============================================================================
module Input
  class << self
    alias update_esms update

    def update
      Mouse.update
      update_esms
    end
  end
end
#===============================================================================
#  start the mouse
#===============================================================================
Mouse.start
