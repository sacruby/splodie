class PlayfieldLayer < Joybox::Core::Layer

  def on_enter

    background = Sprite.new file_name: 'spritesheets/match3bg.png',
    position: [Screen.half_width, Screen.half_height]
    self << background

    @back_button = Sprite.new file_name: 'source_images/backbutton.png', position: [10,10]
    @back_button.setScale = 0.7
    @back_button.setAnchorPoint = [0,0]

    self << @back_button

  end

  def on_exit
    # Tear down
  end

end