class MenuLayer < Joybox::Core::Layer

  def on_enter
    layout_menu
  end

  def on_exit
    # Tear down
  end

  def layout_menu
    size = director.winSize 

    title_label = Label.new text: "splodie!", font_size: 64, color: Color.from_rgb(255, 255, 255), position: [size.width / 2, size.height / 2]
    self << title_label

    MenuLabel.default_font_size = 22
    MenuLabel.default_font_name = "Marker Felt"
    menu_items = Array.new
 
    start_game = MenuLabel.new text: "Start Game", color: Color.from_rgb(255, 255, 255) do |menu_item|
      director.push_scene(PlayfieldScene.new)
    end

    menu_items << start_game

    menu = Menu.new items: menu_items, position: [size.width / 2, size.height / 2 - 50]

    self << menu
  end


end