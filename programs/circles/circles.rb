# tags: circles, oval(), animate{}
# categories: animation, shapes
# description: Places 10 circles randomly.  Each individually giggles randomly..

Shoes.app(
            :width => 300,
            :height => 400
          ) do
 
  fill rgb( 0, 0.6, 0.9, 0.1 )
  stroke rgb( 0, 0.6, 0.9 )
  strokewidth( 0.25 )
 
  @shoes = []
  10.times {
    @shoes.push(
      oval(
        :left => ( -5..self.width ).rand,
        :top => ( -5..self.height ).rand,
        :radius => ( 25..50 ).rand
      )
    )
  }

  animate{ |i|
    @shoes.each { |s|
      s.top += ( -20..20 ).rand
      s.left += ( -20..20 ).rand
    }
  }
end
