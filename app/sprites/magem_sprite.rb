class MagemSprite < Joybox::Core::Sprite

  KGEMANYTYPE = 0
  KGEM1 = 1
  KGEM2 = 2
  KGEM3 = 3
  KGEM4 = 4
  KGEM5 = 5
  KGEM6 = 6
  KGEM7 = 7

  KGEMIDLE = 100
  KGEMMOVING = 101
  KGEMSCORING = 102
  KGEMNEW = 103

  attr_accessor :rowNum, :colNum, :gemType, :gemState, :gameLayer

  def on_enter
    @rowNum = 0
    @colNum = 0
    @gemType = 0
    @gemState = 0
    @gameLayer = nil
  end

  def on_exit
    # Tear down
  end

  def isGemSameAs(otherGem)
    # Is the gem the same type as the other Gem?
    return (self.gemType == otherGem.gemType)
  end

  def isGemInSameRow(otherGem)
    # Is the gem in the same row as the other Gem?
    return (self.rowNum == otherGem.rowNum)
  end

  def isGemInSameColumn(otherGem)
    # Is the gem in the same column as the other gem?
    return (self.colNum == otherGem.colNum)
  end

  def isGemBeside(otherGem)
    # If the row is the same, and the other gem is 
    # +/- 1 column, they are neighbors
    if (isGemInSameRow(otherGem) && 
        ((self.colNum == otherGem.colNum - 1) || 
        (self.colNum == otherGem.colNum + 1))
        )
        return true
    # If the column is the same, and the other gem is 
    # +/- 1 row, they are neighbors
    elsif (isGemInSameColumn(otherGem) && 
                 ((self.rowNum == otherGem.rowNum - 1) || 
                  (self.rowNum == otherGem.rowNum + 1))
                 ) 
        return true
    else 
        return false
    end
  end

#pragma mark Animate the touch
  def highlightGem
    # Build a simple repeating "wobbly" animation
    moveUp = Move.by(0.1, [0,3])
    moveDown = Move.by(0.1, [0,-3])
   
    moveAround = Sequence.with([moveUp, moveDown])

    gemHop = RepeatForever.with(moveAround)
    
    runAction(gemHop)
  end

  def stopHighlightGem
    # Stop all actions (the wobbly) on the gem
    stopAllActions

    # We call to the gameLayer itself to make sure we 
    # haven't left the gem a little off-base
    # (from the highlightGem movements)
    #@gameLayer.performSelector:@selector(resetGemPosition:)
    #                withObject:self];
  end


#pragma mark Touch Detection
  def containsTouchLocation(pos)
    # Was this gem touched?
    return CGRectContainsPoint(self.boundingBox, pos)
  end

end