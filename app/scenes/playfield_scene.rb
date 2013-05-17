class PlayfieldScene < Joybox::Core::Scene

  def on_enter
    playfield_layer = PlayfieldLayer.new
    self << playfield_layer
  end

end