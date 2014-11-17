class NomeLabel < UILabel

  
  def init
    super
    self.font = UIFont.fontWithName("HelveticaNeue-Regular", size: 17)
    self.textColor = UIColor.blackColor
    self.numberOfLines = 0
    self
  end

  
  def configure(data = {})
    if data[:nome]
      attributed_text = NSMutableAttributedString.alloc.initWithString(data[:nome])
      # if data[:complete]
      #   attributed_text.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributed_text.length))
      # end
      self.attributedText = attributed_text
    else
      self.text = ""
    end
  end


end