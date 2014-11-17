class ClienteHeaderCell < UITableViewCell


  #attr_accessor :delegate, :nel_baule


  attr_reader :nel_baule_button, :nome_label, :citta_button


  TOP_BOTTOM_PADDING = 12
  CITTA_HEIGHT = 18
  NOME_E_CITTA_PADDING = 3
  NAME_RIGHT_PADDING_NO_NOTES = 12
  NAME_LEFT_PADDING = 48


  def initWithStyle(style, reuseIdentifier: reuse_identifier)
    super

    self.selectionStyle = UITableViewCellSelectionStyleNone
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    self.contentView.addSubview(@nel_baule_button = NelBauleButton.new)
    self.contentView.addSubview(@nome_label = NomeLabel.new)
    self.contentView.addSubview(@citta_label = CittaLabel.new)
    self.contentView.addSubview(@visita_button = VisitaButton.new)

    @nel_baule_button.setTranslatesAutoresizingMaskIntoConstraints(false)
    @nome_label.setTranslatesAutoresizingMaskIntoConstraints(false)
    @citta_label.setTranslatesAutoresizingMaskIntoConstraints(false)
    @visita_button.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    self
  end

  
  def configure(data = {})
    self.contentView.subviews.each do |sv|
      sv.configure(data)
    end
    self.setNeedsUpdateConstraints
    self.setNeedsLayout
  end


  def updateConstraints
    super

    if @constraints
      self.contentView.removeConstraints(@constraints.flatten)
    end

    @constraints = []

    @constraints << NSLayoutConstraint.constraintsWithVisualFormat(
      'V:|-7-[nel_baule(44)]',
      options: NSLayoutFormatDirectionLeadingToTrailing,
      metrics: nil,
      views: {'nel_baule' => @nel_baule_button}
    )
    @constraints << NSLayoutConstraint.constraintsWithVisualFormat(
      'H:|-1-[nel_baule(44)]',
      options: NSLayoutFormatDirectionLeadingToTrailing,
      metrics: nil,
      views: {'nel_baule' => @nel_baule_button}
    )
    @constraints << NSLayoutConstraint.constraintsWithVisualFormat(
      'V:|-top_padding-[nome]',
      options: NSLayoutFormatDirectionLeadingToTrailing,
      metrics: {'top_padding' => TOP_BOTTOM_PADDING},
      views: {'nome' => @nome_label}
    )
    @constraints << NSLayoutConstraint.constraintsWithVisualFormat(
      'H:[nel_baule]-5-[nome]',
      options: NSLayoutFormatDirectionLeadingToTrailing,
      metrics: nil,
      views: {'nome' => @nome_label, 'nel_baule' => @nel_baule_button}
    )
    @constraints << NSLayoutConstraint.constraintsWithVisualFormat(
      'V:[nome]-nome_and_citta_padding-[citta(==citta_height)]',
      options: NSLayoutFormatAlignAllCenterX,
      metrics: {'nome_and_citta_padding' => NOME_E_CITTA_PADDING, 'citta_height' => CITTA_HEIGHT, 'bottom_padding' => TOP_BOTTOM_PADDING},
      views: {'nome' => @nome_label, 'citta' => @citta_label}
    )
    @constraints << NSLayoutConstraint.constraintsWithVisualFormat(
      'H:[citta(==nome)]',
      options: NSLayoutFormatDirectionLeadingToTrailing,
      metrics: nil,
      views: {'nome' => @nome_label, 'citta' => @citta_label}
    )
    @constraints << NSLayoutConstraint.constraintsWithVisualFormat(
      'H:[name]-right_padding-|',
      options: NSLayoutFormatDirectionLeadingToTrailing,
      metrics: {'right_padding' => self.name_right_padding},
      views: {'notes' => @notes_indicator, 'name' => @nome_label}
    )

    @constraints << NSLayoutConstraint.constraintsWithVisualFormat(
      'H:[visita(==width)]|',
      options: NSLayoutFormatDirectionLeadingToTrailing,
      metrics: {"width" => @visita_button.intrinsicContentSize.width + 16},
      views: {'visita' => @visita_button}
    )

    @constraints << NSLayoutConstraint.constraintWithItem(@visita_button,
                              attribute:NSLayoutAttributeCenterY,
                              relatedBy:NSLayoutRelationEqual,
                                 toItem:self.contentView,
                              attribute:NSLayoutAttributeCenterY,
                             multiplier:1,
                               constant:0)

    self.contentView.addConstraints(@constraints.flatten)
  end


  def current_height_for_width(width)
    name_height = @nome_label.text.boundingRectWithSize(
      [width - NAME_LEFT_PADDING - self.name_right_padding, 0],
      options: NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin,
      attributes: {NSFontAttributeName => @nome_label.font}, 
      context: nil
    ).size.height
    TOP_BOTTOM_PADDING + name_height + NOME_E_CITTA_PADDING + CITTA_HEIGHT + TOP_BOTTOM_PADDING + 0.5
  end

  
  def name_right_padding
    NAME_RIGHT_PADDING_NO_NOTES
  end







  
  # def update(params)
    
  #   if nome = params[:nome]
  #     @nome.text = nome
  #   end

  #   if citta = params[:citta]
  #     @citta.text = citta
  #   end

  #   if nel_baule = params[:nel_baule]
  #     @nel_baule.nel_baule = nel_baule
  #   end

  #   if color = params[:color]
  #     @nel_baule.setColor color
  #     @citta.setColor color
  #   end
  # end

end


