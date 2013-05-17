class PlayfieldLayer < Joybox::Core::Layer

  def on_enter

    isTouchEnabled = true;
    
    size = CCDirector.sharedDirector.winSize
    
    background = Sprite.new file_name: "spritesheets/match3bg.png", position: [Screen.half_width, Screen.half_height]
    self << background

    CCSpriteFrameCache.sharedSpriteFrameCache.addSpriteFramesWithFile("spritesheets/match3sheet.plist")
    @matchSheet = CCSpriteBatchNode.batchNodeWithFile("spritesheets/match3sheet.png", capacity:54)
    addChild(@matchSheet, z:1)

    @back_button = Sprite.new file_name: "source_images/backbutton.png", position: [10, 10]
    @back_button.anchorPoint = [0, 0]
    @back_button.scale = 0.7
    self << @back_button

    # Initialize the sizing of the board
    @boardRows = 5
    @boardColumns = 7
    @boardOffsetWidth = 70
    @boardOffsetHeight = 0
    @padWidth = 4
    @padHeight = 4
    @gemSize = CGSizeMake(45, 45)

    # Total number of unique gems in the game
    @totalGemsAvailable = 7

    # Initialize the arrays
    @gemsInPlay = []
    @gemMatches = []
    @gemsTouched = []
    
    # Set the score to zero
    @playerScore = 0
    @isGameOver = false

    # Preload the sound effects
    # preloadEffects
    
    # Add the score display to the screen
    # generateScoreDisplay
    
    # Add the timer display to the screen
    # generateTimerDisplay
    @startingTimerValue = 60
    @currentTimerValue = @startingTimerValue
    
    generatePlayfield

    drawGemMap(@gemsInPlay)
    
    #[self generateTestingPlayfield];   # FOR DEBUGGING ONLY
    #[self drawGemMap:gemsInPlay];      # FOR DEBUGGING ONLY
    
    # checkMovesRemaining
    
    scheduleUpdate

    on_touches_began do |touches, event|
      director = CCDirector.sharedDirector
      touches.each do |touch|
        location = director.convertToGL(touch.locationInView(touch.view))
        director.pop_scene if CGRectContainsPoint(@back_button.boundingBox, location)
      end
    end

    on_touches_moved do |touches, event|

    end

    on_touches_ended do |touches, event|

    end

    on_touches_cancelled do |touches, event|

    end

  end

  def on_exit
  end

  def update(dt)

    gemsMoving = @gemsInPlay.any? {|g| g.gemState == MagemSprite::KGEMMOVING }
  
    # If we flagged that we need to check the board
    if @checkMatches
        # checkMove
        # checkMovesRemaining
        @checkMatches = false
    end
    
    # Too few gems left.  Let's fill it up.
    # This will avoid any holes if our smartFill left
    # gaps, which is common on 4 and 5 gem matches.
    @addGemsToFillBoard if (@gemsInPlay.size < @boardRows * @boardColumns) && !gemsMoving
    
    # Update the timer value & display
    @currentTimerValue -= dt
    # @timerDisplay.setPercentage((currentTimerValue / startingTimerValue) * 100)
    
    # Game Over / Time's Up
    if @currentTimerValue <= 0
        unscheduleUpdate
        @isGameOver = true
        # gameOver
    end
  end

  #pragma mark Sound Effects
  # def preloadEffects
  #   SimpleAudioEngine.sharedEngine.preloadEffect(SND_SWOOSH)
  #   SimpleAudioEngine.sharedEngine.preloadEffect(SND_DING)
  # end

  # def playSwoosh
  #   SimpleAudioEngine.sharedEngine.playEffect(SND_SWOOSH, pitch:1.0, pan:0, gain:0.25)
  # end

  # def playDing
  #   SimpleAudioEngine.sharedEngine.playEffect(SND_DING)
  # end

  #pragma mark Generate Gem Grid
  def generatePlayfield
    # Randomly select gems and place on the board
    # Iterate through all rows and columns
    (1..@boardRows).each do |row| 
      (1..@boardColumns).each do |col|
        generateGemForRowandColumnofType(row, col, MagemSprite::KGEMANYTYPE) 
      end
    end
    
    # We check for matches now, and remove any gems 
    # from starting in the scoring position
    fixStartingMatches

    # Add the gems to the layer
    @gemsInPlay.each do |g|
      g.gemState = MagemSprite::KGEMIDLE
      @matchSheet.addChild(g)
    end
  end

  def fixStartingMatches
    # This method checks for any possible matches
    # and will remove those gems. After fixing the gems,
    # we call this method again (from itself) until we
    # have a clean result
    checkForMatchesOfType(MagemSprite::KGEMNEW)
    
    if !@gemMatches.empty?
        
        # get the first matching gem
        aGem = @gemMatches[0]

        # Build a replacement gem
        generateGemForRowandColumnofType(aGem.rowNum, aGem.colNum, MagemSprite::KGEMANYTYPE)
            
        # Destroy the original gem
        @gemsInPlay.delete(aGem)
        @gemMatches.delete(aGem)
            
        # We recurse so we can see if the board is clean
        # When we have no gemMatches, we stop recursion
        fixStartingMatches
    end
  end

#pragma mark Generate Individual Gems
  def generateGemForRowandColumnofType(rowNum, colNum, newType)
    
    if newType == MagemSprite::KGEMANYTYPE
        # If we passed a MagemSprite::KGEMANYTYPE, randomize the gem
        gemNum = rand(@totalGemsAvailable) + 1
    else
        # If we passed another value, use that gem type
        gemNum = newType
    end

    # Generate the sprite name
    spritename = "gem#{gemNum}.png"

    # Build the MAGem, which is just an enhanced CCSprite
    thisGem = MagemSprite.spriteWithSpriteFrameName(spritename)
    
    # Set the gem's vars
    thisGem.rowNum = rowNum
    thisGem.colNum = colNum
    thisGem.gemType = gemNum
    thisGem.gemState = MagemSprite::KGEMNEW
    thisGem.gameLayer = self
    
    # Set the position for this gem
    thisGem.position = positionForRowandColumn(rowNum, colNum)

    # Add the gem to the array
    @gemsInPlay << thisGem
    
    # We return the newly created gem, which is already
    # added to the gemsInPlay array
    # It has NOT been added to the layer yet.
    thisGem
  end

  # def addGemForRowandColumnofType(rowNum, colNum, newType)

  #   # Add a replacement gem
  #   thisGem = generateGemForRowandColumnofType(rowNum, colNum, newType)
    
  #   # We reset the gem above the screen
  #   thisGem.setPosition(CGPointAdd(thisGem.position, CGPointMake(0, size.height)))

  #   # Add the gem to the scene
  #   addChild(thisGem)
    
  #   # Drop it to the correct position
  #   moveToNewSlotForGem(thisGem)
  # end

#pragma mark Gem Manipulation
  # def swapGemwithGem(aGem, bGem)
    
  #   # Stop the highlight
  #   aGem.stopHighlightGem
  #   bGem.stopHighlightGem
    
  #   # Grab the temp location of aGem
  #   tempRowNumA = aGem.rowNum
  #   tempColNumA = aGem.colNum

  #   # Set the aGem to the values from bGem
  #   aGem.setRowNum(bGem.rowNum)
  #   aGem.setColNum(bGem.colNum)
    
  #   # Set the bGem to the values from the aGem temp vars
  #   bGem.setRowNum(tempRowNumA)
  #   bGem.setColNum(tempColNumA)
    
  #   # Move the gems
  #   moveToNewSlotForGem(aGem)
  #   moveToNewSlotForGem(bGem)
  # end

  # def moveToNewSlotForGem(aGem)
  #   # Set the gem's state to moving
  #   aGem.setGemState(MagemSprite::KGEMMOVING)

  #   # Move the gem, play sound, let it rest
  #   moveIt = CCMoveTo.actionWithDuration(0.2, position:(positionForRowandColumn(aGem.rowNum, aGem.colNum)))
  #   playSound = CCCallFunc.actionWithTarget(self, selector:"playSwoosh")
  #   gemAtRest = CCCallFuncND.actionWithTarget(self, selector:"gemIsAtRest", data:aGem)
  #   aGem.runAction(CCSequence.actions([moveIt, playSound, gemAtRest]))
  # end

  # def gemIsAtRest(aGem)
  #   # Reset the gem's state to Idle
  #   aGem.setGemState(MagemSprite::KGEMIDLE)
    
  #   # Identify that we need to check for matches
  #   checkMatches = true
  # end

  # def resetGemPosition(aGem)
  #   # Quickly snap the gem back to its desired position
  #   # Used after the gem stops animating
  #   aGem.setPosition(positionForRowandColumn(aGem.rowNum, aGem.colNum))
  # end

  # def animateGemRemoval(aGem)
  #   # We swap the image to "boom", and animate it out
  #   CCCallFuncND *changeImage = [CCCallFuncND
  #           actionWithTarget:self
  #           selector:@selector(changeGemFace:) data:aGem]
  #   CCCallFunc *updateScore = [CCCallFunc
  #           actionWithTarget:self
  #           selector:@selector(incrementScore)]
  #   CCCallFunc *addTime = [CCCallFunc
  #           actionWithTarget:self
  #           selector:@selector(addTimeToTimer)]
  #   CCMoveBy *moveUp = [CCMoveBy actionWithDuration:0.3
  #           position:ccp(0,5)]
  #   CCFadeOut *fade = [CCFadeOut actionWithDuration:0.2]
  #   CCCallFuncND *removeGem = [CCCallFuncND
  #           actionWithTarget:self
  #           selector:@selector(removeGem:) data:aGem]
    
  #   aGem.runAction(CCSequence.actions([changeImage, updateScore, addTime, moveUp, fade, removeGem])
  # end

  # def changeGemFace(aGem)
  #   # Swap the gem texture to the "boom" image
  #   aGem.setDisplayFrame(CCSpriteFrameCache.sharedSpriteFrameCache.spriteFrameByName("boom.png"))
  # end

  # def removeGem(aGem)
  #   # Clean up after ourselves and get rid of this gem
  #   @gemsInPlay.delete(aGem)
  #   aGem.setGemState(MagemSprite::KGEMSCORING)
  #   fillHolesFromGem(aGem)
  #   aGem.removeFromParentAndCleanup(true)
  #   @checkMatches = true
  # end

#pragma mark Scoring 

  # def generateScoreDisplay
  #   # Create the word "score"
  #   scoreTitleLbl = CCLabelTTF.labelWithString("SCORE", fontName:"Marker Felt", fontSize:20)
  #   scoreTitleLbl.setPosition(CGPointAdd(@scorePosition, CGPointMake(0, 20)))
  #   addChild(scoreTitleLbl, z:2)
    
  #   # Generate the display for the actual numeric score
  #   @scoreLabel = CCLabelTTF.labelWithString(@playerScore.to_s, fontName:"Marker Felt" fontSize:18)
  #   @scoreLabel.setPosition(@scorePosition)
  #   addChild(@scoreLabel, z:3)
  # end

  # def incrementScore
  #   # Increment the score and update the display
  #   @playerScore += 1
  #   updateScore
  # end

  # def updateScore
  #   # Update the score label with the new score value
  #   @scoreLabel = @playerScore.to_s
  # end

  # pragma mark Timer & Game Over

  # def generateTimerDisplay
  #   @timerFrame = CCSprite:spriteWithFile('timer.png')
  #   @timerFrame.setPosition(@timerPosition)

  #   # Create a sprite for the timer
  #   @timerSprite = CCSprite:spriteWithFile('timer_back.png')

  #   # Add the timer itself
  #   @timerDisplay = CCProgressTimer:progressWithSprite(@timerSprite)
  #   @timerDisplay.setPosition(@timerPosition)
  #   @timerDisplay.setType(KCCProgressTimerTypeRadial)
  #   addChildz(@timerDisplay, 4) # questionable: [self addChild:timerDisplay z:4]
  #   @timerDisplay.setPercentage(100)

  #   nil
  # end

  # def addTimeToTimer
  #   # Add 1 second to clock
  #   @currentTimerValue += 1

  #   # If we are full, take it back to maximum
  #   if @currentTimerValue > @startingTimeValue
  #     @currentTimerValue = @startingTimeValue

  #   nil
  # end

  # def gameOver
  #   # Add a basic Game Over text
  #   @gameOverLabel = CCLabelTTF:labelWithString:fontName:fontSize('Game Over', 'Marker Felt', 60)
  #   @gameOverLabel.setPosition([size.width/2 - 4, size.height/2 - 4])
  #   addChildz(@gameOverLabel, 50) # questionable: [self addChild:gameOverLabel z:50]

  #   # Add a second Game Over text, as a simple drop shadow
  #   @gameOverLabelShadow = CCLabelTTF:labelWithString:fontName:fontSize('Game Over', 'Marker Felt', 60)
  #   @gameOverLabelShadow.setPosition([size.width/2 - 4, size.height/2 - 4])
  #   addChildz(@gameOverLabelShadow, 49) # questionable: [self addChild:gameOverLabel z:49]

  #   nil
  # end

#pragma mark Match Checking (actual board)
  def checkForMatchesOfType(desiredGemState)
    # This method checks for any 3 in a row matches,
    # and stores the resulting "scoring matches" in
    # the gemMatches array
    
    # We use the desiredGemState parameter to check for
    # MagemSprite::KGEMIDLE or MagemSprite::KGEMNEW, depending on whether the
    # game is in play or if it is initial board creation
    
    # Let's look for horizontal matches
    @gemsInPlay.each do |aGem|
      # Let's grab the first gem
      if aGem.gemState == desiredGemState
        # If it is the desired state, let's look
        # for a matching neighbor gem
        @gemsInPlay.each do |bGem|
          # If the gem is the same type and state,
          # in the same row, and to the right
          if (aGem.isGemSameAs(bGem) &&
                aGem.isGemInSameRow(bGem) &&
            aGem.colNum == bGem.colNum - 1 &&
            bGem.gemState == desiredGemState)
            # Now we loop through again,
            # looking for a 3rd in a row
            @gemsInPlay.each do |cGem|
              # If this is the 3rd gem in a row
              # in the desired state
              if (aGem.colNum == cGem.colNum - 2 &&
                cGem.gemState == desiredGemState)
                # Is the gem the same type
                # and in the same row?
                if (aGem.isGemSameAs(cGem) &&
                    aGem.isGemInSameRow(cGem))
                  # Add gems to match array
                  addGemToMatch(aGem)
                  addGemToMatch(bGem)
                  addGemToMatch(cGem)
                  break
                end
              end
            end
          end
        end
      end

      # Let's look for vertical matches 
      @gemsInPlay.each do |aGem|
        # Let's grab the first gem
        if (aGem.gemState == desiredGemState)
          # If it is the desired state, let's look for a matching neighbor gem
          @gemsInPlay.each do |bGem|
            # If the gem is the same type and state, in the same column, and above
            if (aGem.isGemSameAs(bGem) &&
              aGem.isGemInSameColumn(bGem) &&
              aGem.rowNum == bGem.rowNum - 1 &&
              bGem.gemState == desiredGemState)
              # Now we loop through again, looking for a 3rd in the column
              @gemsInPlay.each do |cGem|
                # If this is the 3rd gem in a row in the desired state
                if (bGem.rowNum == cGem.rowNum - 1 &&
                  cGem.gemState == desiredGemState)
                  # Is the gem the same type and in the same column?
                  if (bGem.isGemSameAs(cGem) &&
                    bGem.isGemInSameColumn(cGem))
                    # Add gems to match array
                    addGemToMatch(aGem)
                    addGemToMatch(bGem)
                    addGemToMatch(cGem)
                    break
                  end 
                end
              end
            end
          end 
        end
      end
    end
  end

  def addGemToMatch(thisGem)
    # Only adds it to the array if it isn't already there
    @gemMatches << thisGem unless @gemMatches.include?(thisGem)
  end

  def positionForRowandColumn(rowNum, colNum)
    
    x = @boardOffsetWidth + ((@gemSize.width + @padWidth) * colNum)
    y = @boardOffsetHeight + ((@gemSize.height + @padHeight) * rowNum)
    
    CGPointMake(x, y)
  end

#//////////////////////////

#pragma mark Touch Handlers
  def ccTouchBegan(touch, event)
    
    CGPoint location = touch.locationInView(touch.view)
    CGPoint convLoc = director.convertToGL(location)
    
    # If we reached game over, any touch returns to menu
    if @isGameOver
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
        @gemsInPlay.each do |aGem|
          # If the gem was touched AND the gem is idle,
          # return YES to track the touch
          if aGem.containsTouchLocation(convLoc) &&
                            aGem.gemState == MagemSprite::KGEMIDLE
            return true
          end
        end
    end

    # If we failed to find any good touch, return
    false
  end

  def ccTouchMoved(touch, event)
    # Swipes are handled here.
    touchHelper(touch, event)
  end

  def ccTouchEnded(touch, event)
    # Taps are handled here.    
    touchHelper(touch, event)
  end

  def touchHelper(touch, event)
    # If we're already checking for a match, ignore
    if (@gemsTouched.length >= 2 || @gemsMoving) 
        return
    end
    
    location = touch.locationInView(touch.view)
    convLoc = director.convertToGL(location)
    
    # Let's figure out which gem was touched (if any)
    @gemsInPlay.each do |aGem|
        if aGem.containsTouchLocation(convLoc) && aGem.gemState == MagemSprite::KGEMIDLE
            # We can't add the same gem twice
            unless @gemsTouched.include?(aGem)
                # Add the gem to the array
                playDing
                @gemsTouched << aGem
                aGem.highlightGem
            end
        end
    end
    
    # We now have touched 2 gems.  Let's swap them.
    if @gemsTouched.length >= 2
        aGem = @gemsTouched[0]
        bGem = @gemsTouched[1]
        
        # If the gems are adjacent, we can swap
        if aGem.isGemBeside(bGem)
          swapGemwithGem(aGem,bGem)
        else
            # They're not adjacent, so let's drop
            # the first gem
            aGem.stopHighlightGem
            @gemsTouched.delete(aGem)
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
    
    NSLog(map5)
    NSLog(map4)
    NSLog(map3)
    NSLog(map2)
    NSLog(map1)
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
    @gemsInPlay.each do |aGem|
      aGem.gemState = MagemSprite::KGEMIDLE
      @matchsheet.addChild(aGem)
    end
    
    checkMovesRemaining
    
    NSLog("test created #{movesRemaining} movesRemaining")
  end

end

