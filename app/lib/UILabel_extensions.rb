class UILabel

  def sizeToFitWithAlignmentRight
    beforeFrame = self.frame
    self.sizeToFit
    afterFrame = self.frame
    self.frame = CGRectMake(beforeFrame.origin.x + beforeFrame.size.width - afterFrame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height)
  end
  
end