class IntroLayer < Joybox::Core::Layer
  scene

  def on_enter
    director.replace_scene MenuScene.new
  end

  def on_exit
    # Tear down
  end

end