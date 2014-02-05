class AppuntoCell < SWTableViewCell 


  def rmq_build
    rmq(self).apply_style :appunto_cell

    rmq(self.contentView).tap do |q|
      @note         = q.append(UITextView, :note).get
      @updated_at   = q.append(UILabel,    :updated_at).get

      @image_baule  = q.append(UIImageView, :image_baule).get
      @image_status = q.append(UIImageView, :image_status).get
      @image_phone  = q.append(UIImageView, :image_phone).get
    end
  end


  def update(params)

    if status = params[:status]
      @image_status.image = "icon-#{status}-on35".uiimage
    end

    if updated_at = params[:updated_at]
      if updated_at.day == Time.now.day
        @updated_at.text = 'oggi'
      elsif updated_at.year == Time.now.year
        @updated_at.text = rmq.format.date(updated_at, "d MMM")
      else
        @updated_at.text = rmq.format.date(updated_at, "MMM yyyy")
      end
      @updated_at.sizeToFitWithAlignmentRight
    end
    
    str = "".attrd

    if params[:destinatario] && !params[:destinatario].blank?

      if params[:show_cliente] == true
        destinatario_attrd = {
          NSForegroundColorAttributeName => rmq.color.dark_gray,
          NSFontAttributeName => rmq.font.with_name('Helvetica', 16)
        }   
      else
        destinatario_attrd = {
          NSForegroundColorAttributeName => rmq.color.black,
          NSFontAttributeName => rmq.font.with_name('Helvetica', 18)
        }   
      end  
      str =  str + params[:destinatario].attrd(destinatario_attrd) + "\n"
    end
    
    if params[:show_cliente] && params[:show_cliente] == true
      if params[:cliente_nome] && !params[:cliente_nome].blank?
        cliente_nome_attrd = {
          NSForegroundColorAttributeName => rmq.color.black,
          NSFontAttributeName => rmq.font.with_name('Helvetica', 18)
        }     
        str =  str + params[:cliente_nome].attrd(cliente_nome_attrd) + "\n"
      end
    end

    if params[:note] && !params[:note].blank?
      note_attrd = {
        NSForegroundColorAttributeName => rmq.color.light_gray,
        NSFontAttributeName => rmq.font.with_name('HelveticaNeue', 14)
      }     
      str =  str + params[:note].attrd(note_attrd) + "\n"
    end

    exclusionPath = UIBezierPath.bezierPathWithRect CGRectMake( @updated_at.frame.origin.x - 35, @updated_at.frame.origin.y - 5, @updated_at.frame.size.width, @updated_at.frame.size.height)
    @note.textContainer.exclusionPaths = [exclusionPath]    
    
    @note.attributedText = str

    if nel_baule = params[:nel_baule]
      if nel_baule == 1
        @image_baule.image = "icon-nel_baule-on35".uiimage
      else
        @image_baule.image = nil
      end
    end

    if params[:telefono] && !params[:telefono].blank?
      @image_phone.image = "735-phone-selected".uiimage
    else
      @image_phone.image = nil
    end
  end

end
