class LibriCell < UITableViewCell 


  def rmq_build
    rmq(self).apply_style :libri_cell

    rmq(self.contentView).tap do |q|
      @titolo =    q.append(UILabel, :titolo).get
      @prezzo_copertina = q.append(UILabel, :prezzo_copertina).get
      @copertina = q.append(UIImageView, :copertina).get
    end
  end


  def update(params)
    if titolo = params[:titolo]
      @titolo.text = titolo
    end

    if prezzo_copertina = params[:prezzo_copertina]
      @prezzo_copertina.text = "prezzo cad. #{prezzo_copertina.string_with_style(:currency)}"
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
