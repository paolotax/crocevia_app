class CircleButton < UIButton

  attr_reader :nel_baule

  def initWithColor(color, andValue:value)
    init
    setColor(color)
    nel_baule = value
    self
  end


  def setColor(color)
    @color = color
  end

  
  def nel_baule=(nel_baule)
    @nel_baule = nel_baule
    self.setNeedsDisplay
  end
  

  def drawRect(rect)

    context = UIGraphicsGetCurrentContext()

    if nel_baule == 1
      baseColor = @color || UIColor.colorWithRed( 0.667, green:0.667, blue:0.667, alpha:1)
    else
      baseColor = UIColor.colorWithRed( 0.667, green:0.667, blue:0.667, alpha:1)
    end

    # if Device.simulator?
      baseColorH  = Pointer.new(:double, 1)
      baseColorS  = Pointer.new(:double, 1)
      baseColorBr = Pointer.new(:double, 1)
      baseColorAl = Pointer.new(:double, 1)
    # else
    #   baseColorH  = Pointer.new(:float, 1)
    #   baseColorS  = Pointer.new(:float, 1)
    #   baseColorBr = Pointer.new(:float, 1)
    #   baseColorAl = Pointer.new(:float, 1)      
    # end

    baseColor.getHue baseColorH, saturation: baseColorS, brightness: baseColorBr, alpha: baseColorAl

    circleOuterColor = UIColor.colorWithHue baseColorH[0], saturation: baseColorS[0], brightness: 0.5, alpha: baseColorAl[0]

    if nel_baule == 1
      shadow = circleOuterColor
      shadowOffset = CGSizeMake(0.1, 1.1)
      shadowBlurRadius = 1.5
    end

    ovalOuterPath = UIBezierPath.bezierPathWithOvalInRect CGRectMake(9, 9, 26, 26)
    circleOuterColor.setStroke
    ovalOuterPath.lineWidth = 1
    ovalOuterPath.stroke

    if nel_baule == 1

      ovalInnerPath = UIBezierPath.bezierPathWithOvalInRect CGRectMake(12, 12, 20, 20)
      baseColor.setFill
      ovalInnerPath.fill

      ovalInnerBorderRect = CGRectInset(ovalInnerPath.bounds, -shadowBlurRadius, -shadowBlurRadius)
      ovalInnerBorderRect = CGRectOffset(ovalInnerBorderRect, -shadowOffset.width, -shadowOffset.height)
      ovalInnerBorderRect = CGRectInset(CGRectUnion(ovalInnerBorderRect, ovalInnerPath.bounds), -1, -1)

      ovalInnerNegativePath = UIBezierPath.bezierPathWithRect(ovalInnerBorderRect)
      ovalInnerNegativePath.appendPath(ovalInnerPath)
      ovalInnerNegativePath.usesEvenOddFillRule = true

      CGContextSaveGState(context)
      # {      
        xOffset = shadowOffset.width + ovalInnerBorderRect.size.width.ceil
        yOffset = shadowOffset.height
        
        CGContextSetShadowWithColor( context, CGSizeMake(xOffset + 0.1, yOffset + 0.1), shadowBlurRadius, shadow.CGColor)

        ovalInnerPath.addClip
        transform = CGAffineTransformMakeTranslation(-ovalInnerBorderRect.size.width.ceil, 0)
        ovalInnerNegativePath.applyTransform(transform)
        UIColor.grayColor.setFill
        ovalInnerNegativePath.fill
      # }
      CGContextRestoreGState(context)
    end
  end

end