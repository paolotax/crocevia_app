class TotaliCell < UITableViewCell

  attr_accessor :copertina
  attr_reader :reused

  def rmq_build
    rmq(self).apply_style :totali_cell

    rmq(self.contentView).tap do |q|
      # Add your subviews, init stuff here
      @importo =  q.append(UILabel, :importo).get
      @copie =    q.append(UILabel, :copie).get
    end
  end

  
  def prepareForReuse
    @reused = true
  end


  def update(params)
    if importo = params[:importo]
      @importo.text = "#{importo.string_with_style(:currency)}"
    end

    if copie = params[:copie]
      @copie.text = "#{copie} copie"
    end
  end
end


# To style this view include its stylesheet at the top of each controller's 
# stylesheet that is going to use it:
#   class SomeStylesheet < ApplicationStylesheet 
#     include TotaliCellStylesheet

# Another option is to use your controller's stylesheet to style this view. This
# works well if only one controller uses it. If you do that, delete the 
# view's stylesheet with:
#   rm app/stylesheets/views/totali_cell.rb
