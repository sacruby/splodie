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

  # pragma mark Timer & Game Over

  def generateTimerDisplay
    @timerFrame = CCSprite:spriteWithFile('timer.png')
    @timerFrame.setPosition(@timerPosition)

    # Create a sprite for the timer
    @timerSprite = CCSprite:spriteWithFile('timer_back.png')

    # Add the timer itself
    @timerDisplay = CCProgressTimer:progressWithSprite(@timerSprite)
    @timerDisplay.setPosition(@timerPosition)
    @timerDisplay.setType(KCCProgressTimerTypeRadial)
    addChildz(@timerDisplay, 4) # questionable: [self addChild:timerDisplay z:4]
    @timerDisplay.setPercentage(100)

    nil
  end

  def addTimeToTimer
    # Add 1 second to clock
    @currentTimerValue += 1

    # If we are full, take it back to maximum
    if @currentTimerValue > @startingTimeValue
      @currentTimerValue = @startingTimeValue

    nil
  end

  def gameOver
    # Add a basic Game Over text
    @gameOverLabel = CCLabelTTF:labelWithString:fontName:fontSize('Game Over', 'Marker Felt', 60)
    @gameOverLabel.setPosition([size.width/2 - 4, size.height/2 - 4])
    addChildz(@gameOverLabel, 50) # questionable: [self addChild:gameOverLabel z:50]

    # Add a second Game Over text, as a simple drop shadow
    @gameOverLabelShadow = CCLabelTTF:labelWithString:fontName:fontSize('Game Over', 'Marker Felt', 60)
    @gameOverLabelShadow.setPosition([size.width/2 - 4, size.height/2 - 4])
    addChildz(@gameOverLabelShadow, 49) # questionable: [self addChild:gameOverLabel z:49]

    nil
  end

end