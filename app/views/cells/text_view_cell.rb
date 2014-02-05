class TextViewCell < UITableViewCell

  attr_accessor :text_view
  attr_reader :reused

  def rmq_build
    
    rmq(self).apply_style :text_view_cell

    rmq(self.contentView).tap do |q|
      @text_view =  q.append(UITextView, :text_view).get
    end
  end

  
  def prepareForReuse
    @reused = true
  end

  
  def update(params)
    if text_view = params[:text_view]
      @text_view.text = text_view
    end
  end


end