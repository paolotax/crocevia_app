class TextFieldCell < UITableViewCell

  attr_accessor :text_field
  attr_reader :reused

  def rmq_build
    
    rmq(self).apply_style :text_field_cell

    rmq(self.contentView).tap do |q|
      @text_label = q.append(UILabel, :text_label).get
      @text_field = q.append(UITextField, :text_field).get
    end
  end

  
  def prepareForReuse
    @reused = true
  end

  
  def update(params)
    if text_label = params[:text_label]
      @text_label.text = text_label
    end

    if text_field = params[:text_field]
      @text_field.text = text_field
    end
  end


end