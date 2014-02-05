class AppuntiCollectionCell < UICollectionViewCell 
  attr_reader :reused

  def rmq_build
    rmq(self).apply_style :appunti_cell

    rmq(self.contentView).tap do |q|
      @cliente_nome = rmq.append(UILabel, :cliente_nome).get
      @destinatario = rmq.append(UILabel, :destinatario).get
      @note         = rmq.append(UITextView, :note).get
      @image_baule  = rmq.append(UIImageView, :image_baule).get
      @image_status = rmq.append(UIImageView, :image_status).get
      @image_cloud  = rmq.append(UIImageView, :image_cloud).get
    end
  end

  def prepareForReuse
    @reused = true
  end


  def update(params)

    if cliente_nome = params[:cliente_nome]
      @cliente_nome.text = cliente_nome
    end

    if destinatario = params[:destinatario]
      @destinatario.text = destinatario
    end

    if note = params[:note]
      @note.text = note
    end

    if status = params[:status]
      @image_status.image = "icon-#{status}-on35".uiimage
    end

    if nel_baule = params[:nel_baule]
      if nel_baule == 1
        @image_baule.image = "icon-nel_baule-on35".uiimage
      else
        @image_baule.image = "icon-nel_baule-off35".uiimage
      end
    end

    if image_cloud = params[:image_cloud]

    end
  end

end
