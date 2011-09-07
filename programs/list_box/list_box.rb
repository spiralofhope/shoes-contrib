# tags: list_box
# categories: elements

Shoes.app do
  stack :margin => 10 do
    para "Pick a card:"
    list_box :items => ["Jack", "Ace", "Joker"]
  end
end
