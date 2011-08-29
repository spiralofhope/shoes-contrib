# Try changing the shape of the window.

xspeed = 8.4
yspeed = 6.6
xdir = 1
ydir = 1

Shoes.app do
  background "#DFA"
  border(
    black,
    :strokewidth => 6
  )
  nostroke
  @icon = image(
      "#{DIR}/static/shoes-icon.png",
      :left => 100,
      :top => 100
    ) do
    # When clicked.
    alert "You're soooo quick."
  end

  x = self.width / 2
  y = self.height / 2
  size = @icon.size
  animate( 30 ) do
    x = x + xspeed * xdir
    y = y + yspeed * ydir
    
    xdir *= -1 if x > self.width  - size[0] or x < 0
    ydir *= -1 if y > self.height - size[1] or y < 0

    @icon.move x.to_i, y.to_i
  end
end
