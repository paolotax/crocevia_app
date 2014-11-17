class NelBauleButton < UIButton
  

  def init
    super
    self.addSubview(@image_view = UIImageView.new)
    @image_view.frame = [[10, 15], [20, 20]]
    # @image_view.layer.cornerRadius = 10
    # @image_view.layer.borderColor = COLORS[0].CGColor
    # @image_view.layer.borderWidth = 2.0

    self
  end

  
  def configure(data = {})
    #puts data[:nel_baule]
    if data[:nel_baule] && data[:nel_baule] == 1
      @image_view.image = UIImage.imageNamed("icon-nel_baule-on35")
    else
      @image_view.image = UIImage.imageNamed("icon-nel_baule-off35")
    end
  end


end