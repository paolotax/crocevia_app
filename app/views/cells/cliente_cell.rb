class ClienteCell < UITableViewCell

  attr_accessor :delegate, :nel_baule
  attr_reader :reused

  def rmq_build
    
    rmq(self).apply_style :cliente_cell

    rmq(self.contentView).tap do |q|
      @nome =  q.append(UILabel, :nome).get
      @citta = q.append(UILabel, :citta).get
      @nel_baule = q.append(CircleButton.alloc.initWithColor(COLORS[3], andValue:false), :nel_baule).on(:tap) do
        if (self.delegate.respondsToSelector('clienteCellDidTapBaule:'))
          self.delegate.clienteCellDidTapBaule(self)
        end
      end.get
    end
  end

  def prepareForReuse
    @reused = true
  end

  def update(params)
    if nome = params[:nome]
      @nome.text = nome
    end

    if citta = params[:citta]
      @citta.text = citta
    end

    if nel_baule = params[:nel_baule]
      @nel_baule.nel_baule = nel_baule
    end

    if color = params[:color]
      @nel_baule.setColor color
      @citta.setColor color
    end
  end

end


# To style this view include its stylesheet at the top of each controller's 
# stylesheet that is going to use it:
#   class SomeStylesheet < ApplicationStylesheet 
#     include ClienteCellStylesheet

# Another option is to use your controller's stylesheet to style this view. This
# works well if only one controller uses it. If you do that, delete the 
# view's stylesheet with:
#   rm app/stylesheets/views/cliente_cell.rb
