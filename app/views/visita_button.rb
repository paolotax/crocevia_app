class VisitaButton < UIButton
  

  def init
    super
    
    # self.frame = [[200, 10], [100, 44]]
    
    self.layer.cornerRadius = 3
    self.layer.borderColor = rmq.color.light_gray.CGColor
    self.layer.borderWidth = 1

    self.titleLabel.text = "Check In"
    
    self.contentEdgeInsets = UIEdgeInsetsMake(3.0, -3.0, 3.0, -3.0)
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter
    

    self
  end

  
  def configure(data = {})


    # if data[:note] && !data[:note].blank?
    #   note_attrd = {
    #     NSForegroundColorAttributeName => rmq.color.light_gray,
    #     NSFontAttributeName => rmq.font.with_name('HelveticaNeue', 14)
    #   }     
    #   str =  str + data[:note].attrd(note_attrd) + "\n"
    # end


    if visita = data[:visita]

      pretty_visita =  MHPrettyDate.prettyDateFromDate(visita, withFormat:MHPrettyDateFormatNoTime)
      
      if MHPrettyDate.isToday(visita) || MHPrettyDate.isTomorrow(visita) || MHPrettyDate.isYesterday(visita)
        
        attributedText = NSAttributedString.alloc.initWithString(
                      "#{pretty_visita}",
          attributes: { 
            NSFontAttributeName => UIFont.fontWithName("HelveticaNeue-Light", size:14),
            NSForegroundColorAttributeName => COLORS[3]

          }
        )   
      
      else

        visita_array = rmq.format.date(visita, "EEEE d MMM").split(" ")

        attributed_giorno = {
          NSForegroundColorAttributeName => rmq.color.light_gray,
          NSFontAttributeName => rmq.font.with_name('HelveticaNeue-Light', 10)
        }

        attributed_data = {
          NSForegroundColorAttributeName => rmq.color.black,
          NSFontAttributeName => rmq.font.with_name('HelveticaNeue', 18)
        }

        attributed_mese = {
          NSForegroundColorAttributeName => rmq.color.light_gray,
          NSFontAttributeName => rmq.font.with_name('HelveticaNeue-Light', 10)
        }

        attributedText = visita_array[0].attrd(attributed_giorno) + "\n" + visita_array[1].attrd(attributed_data)  + "\n" + visita_array[2].attrd(attributed_mese)
    
      end
      self.setAttributedTitle attributedText, forState: UIControlStateNormal

    else
      self.setTitle "...", forState: UIControlStateNormal
    end
  end


end