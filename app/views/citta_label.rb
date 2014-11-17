class CittaLabel < UILabel

  def init
    super
    self.font = UIFont.fontWithName("HelveticaNeue-Light", size: 15)
    self.textColor = "8E8E93".uicolor
    self.numberOfLines = 1
    self
  end

  
  def configure(data = {})
    if data[:citta]
      attributed_text = NSMutableAttributedString.alloc.initWithString(data[:citta])
      self.attributedText = attributed_text
    else
      self.text = ""
    end
  end


end