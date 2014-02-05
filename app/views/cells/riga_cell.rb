class RigaCell < UITableViewCell


  attr_reader :reused


  def rmq_build
    rmq(self).apply_style :riga_cell

    rmq(self.contentView).tap do |q|
      # Add your subviews, init stuff here
      @titolo =    q.append(UILabel, :titolo).get
      @quantita =  q.append(UILabel, :quantita).get
      @prezzo_unitario = q.append(UILabel, :prezzo_unitario).get
      @copertina = q.append(UIImageView, :copertina).get
    end
  end

  
  def prepareForReuse
    @reused = true
  end


  def update(params)
    if titolo = params[:titolo]
      @titolo.text = titolo
    end

    if quantita = params[:quantita]
      @quantita.text = "copie #{quantita}"
    end

    if prezzo_unitario = params[:prezzo_unitario]
      @prezzo_unitario.text = "prezzo cad. #{prezzo_unitario.string_with_style(:currency)}"
    end

    if image_url = params[:image_url]
      @copertina.image = nil
      imageURL = NSURL.URLWithString image_url
      if (imageURL) 
        download_task = rmq.app.delegate.url_session.dataTaskWithURL(imageURL,
          completionHandler: 
            lambda do |data, response, error|
              if error
                #NSLog("ERROR: %@", error)
              else             
                httpResponse = response;
                if (httpResponse.statusCode == 200)
                  image = UIImage.imageWithData(data)                
                  Dispatch::Queue.main.async do
                    @copertina.image = image
                  end
                else
                  #NSLog("Couldn't load image at URL: %@", imageURL)
                  #NSLog("HTTP %d", httpResponse.statusCode)
                end
              end
            end
          )
        download_task.resume
      end
    end
  end

end
