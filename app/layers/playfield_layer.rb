class PlayfieldLayer < Joybox::Core::Layer

  def on_enter

    background = Sprite.new file_name: 'spritesheets/match3bg.png',
    position: [Screen.half_width, Screen.half_height]
    self << background

    @back_button = Sprite.new file_name: 'source_images/backbutton.png', position: [10,10]
    # @back_button.setScale = 0.7

    self << @back_button

    test_gem = MagemSprite.new file_name: 'source_images/gem1.png', position: [140, 140]
    self << test_gem

  end

  def on_exit
    # Tear down
  end

  # pragma mark Timer & Game Over

  def generateTimerDisplay
    timerFrame = Sprite.new file_name: 'timer.png', position: [10, 300]
    self << timerFrame
    # Create a sprite for the timer
    @timerSprite = Sprite.new file_name: 'timer_back.png'

    # Add the timer itself
    @timerDisplay = ProgressTimer.progressWithSprite(@timerSprite)
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
    end
    
    nil
  end

  def gameOver
    # Add a basic Game Over text Screen.half_width, Screen.half_height
    @gameOverLabel = Label.new(text: 'Game Over', font_name: 'Marker Felt', font_size: 60)
    @gameOverLabel.setPosition([Screen.half_width - 4, Screen.half_height - 4])
    
    addChildz(@gameOverLabel, 50) # questionable: [self addChild:gameOverLabel z:50]

    # Add a second Game Over text, as a simple drop shadow
    @gameOverLabelShadow = Label.new(text: 'Game Over', font_name: 'Marker Felt', font_size: 60)
    @gameOverLabelShadow.setPosition([Screen.half_width - 4, Screen.half_height - 4])
    addChildz(@gameOverLabelShadow, 49) # questionable: [self addChild:gameOverLabel z:49]

    nil
  end

#pragma mark Touch Handlers
def ccTouchBegan(touch, event)
    
    CGPoint location = touch.locationInView(touch.view)
    CGPoint convLoc = director.convertToGL(location)
    
    # If we reached game over, any touch returns to menu
    if isGameOver
      director.replace_scene(MenuScene.scene)
      return true
    end

    # If the back button was pressed, we exit
    if CGRectContainsPoint(backButton.boundingBox, convLoc)
        director.replace_scene(MenuScene.node)
        return true
    end

    # If we have only 0 or 1 gem in gemsTouched, track
    if gemsTouched.length < 2
        # Check each gem
        gemsInPlay.each do |aGem|
          # If the gem was touched AND the gem is idle,
          # return YES to track the touch
          if aGem.containsTouchLocation(convLoc) &&
                            aGem.gemState == kGemIdle
                return true
          end
        end
    end

    # If we failed to find any good touch, return
    return false
end

def ccTouchMoved(touch,event)
    # Swipes are handled here.
    touchHelper(touch, event)
end

def ccTouchEnded(touch, event)
    # Taps are handled here.    
    touchHelper(touch,event)
end

def touchHelper(touch, event)
    # If we're already checking for a match, ignore
    if (gemsTouched.length >= 2 || gemsMoving) 
        return
    end
    
    location = touch.locationInView(touch.view)
    convLoc = director.convertToGL(location)
    
    # Let's figure out which gem was touched (if any)
    gemsInPlay.each do |aGem|
        if aGem.containsTouchLocation(convLoc) && aGem.gemState == kGemIdle 
            # We can't add the same gem twice
            unless gemsTouched.include?(aGem)
                # Add the gem to the array
                playDing
                gemsTouched << aGem
                aGem.highlightGem
            end
        end
    end
    
    # We now have touched 2 gems.  Let's swap them.
    if gemsTouched.length >= 2
        aGem = gemsTouched[0]
        bGem = gemsTouched[1]
        
        # If the gems are adjacent, we can swap
        if aGem.isGemBeside(bGem)
          swapGemwithGem(aGem,bGem)
        else
            # They're not adjacent, so let's drop
            # the first gem
            aGem.stopHighlightGem
            gemsTouched.delete(aGem)
        end
    end
end

#pragma mark Brute Force Debugging Tools
 def drawGemMap(sourceArray)
    # Brute force debugger, produces a grid of numbers in the output window
    map = []
    
    sourceArray.each do |aGem|
      map[aGem.rowNum] ||= []
      map[aGem.rowNum][aGem.colNum] = aGem.gemType;
    end    

    map1 = "#{map[1][1]} #{map[1][2]} #{map[1][3]} #{map[1][4]} #{map[1][5]} #{map[1][6]} #{map[1][7]}"
    
    map2 = "#{map[2][1]} #{map[2][2]} #{map[2][3]} #{map[2][4]} #{map[2][5]} #{map[2][6]} #{map[2][7]}"
    map3 = "#{map[3][1]} #{map[3][2]} #{map[3][3]} #{map[3][4]} #{map[3][5]} #{map[3][6]} #{map[3][7]}"
    
    map4 = "#{map[4][1]} #{map[4][2]} #{map[4][3]} #{map[4][4]} #{map[4][5]} #{map[4][6]} #{map[4][7]}"
    
    map5 = "#{map[5][1]} #{map[5][2]} #{map[5][3]} #{map[5][4]} #{map[5][5]} #{map[5][6]} #{map[5][7]}"
    
    map6 = "#{map[6][1]} #{map[6][2]} #{map[6][3]} #{map[6][4]} #{map[6][5]} #{map[6][6]} #{map[6][7]}"
    
    puts map6
    puts map5
    puts map4
    puts map3
    puts map2
    puts map1
end

def generateTestingPlayfield 
    # // This generates a testing playfield that looks like:
    # //
    # // 3322122
    # // 6565241
    # // 1127334
    # // 7654721
    # // 7651234
    # // 1234567
    
    generateGemForRowandColumnofType(1,1,1)
    generateGemForRowandColumnofType(1,2,2)
    generateGemForRowandColumnofType(1,3,3)
    generateGemForRowandColumnofType(1,4,4)
    generateGemForRowandColumnofType(1,5,5)
    generateGemForRowandColumnofType(1,6,6)
    generateGemForRowandColumnofType(1,7,7)
    
    generateGemForRowandColumnofType(2,1,7)
    generateGemForRowandColumnofType(2,2,6)
    generateGemForRowandColumnofType(2,3,5)
    generateGemForRowandColumnofType(2,4,1)
    generateGemForRowandColumnofType(2,5,2)
    generateGemForRowandColumnofType(2,6,3)
    generateGemForRowandColumnofType(2,7,4)
    
    generateGemForRowandColumnofType(3,1,7)
    generateGemForRowandColumnofType(3,2,6)
    generateGemForRowandColumnofType(3,3,5)
    generateGemForRowandColumnofType(3,4,4)
    generateGemForRowandColumnofType(3,5,7)
    generateGemForRowandColumnofType(3,6,2)
    generateGemForRowandColumnofType(3,7,1)
    
    generateGemForRowandColumnofType(4,1,1)
    generateGemForRowandColumnofType(4,2,1)
    generateGemForRowandColumnofType(4,3,2)
    generateGemForRowandColumnofType(4,4,7)
    generateGemForRowandColumnofType(4,5,3)
    generateGemForRowandColumnofType(4,6,3)
    generateGemForRowandColumnofType(4,7,4)

    generateGemForRowandColumnofType(5,1,6)
    generateGemForRowandColumnofType(5,2,5)
    generateGemForRowandColumnofType(5,3,6)
    generateGemForRowandColumnofType(5,4,5)
    generateGemForRowandColumnofType(5,5,2)
    generateGemForRowandColumnofType(5,6,4)
    generateGemForRowandColumnofType(5,7,1)
    
    generateGemForRowandColumnofType(6,1,3)
    generateGemForRowandColumnofType(6,2,3)
    generateGemForRowandColumnofType(6,3,2)
    generateGemForRowandColumnofType(6,4,2)
    generateGemForRowandColumnofType(6,5,1)
    generateGemForRowandColumnofType(6,6,2)
    generateGemForRowandColumnofType(6,7,2)
        
    #  Add the gems to the layer
    gemsInPlay.each do |aGem|
      aGem.setGemState(kGemIdle)
      matchsheet.addChild(aGem)
    end
    
    # [self checkMovesRemaining];
    
    puts "test created #{movesRemaining} movesRemaining"
  end

end