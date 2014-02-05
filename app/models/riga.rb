class Riga < CDQManagedObject

  def calc_prezzo
    (prezzo_unitario * (100 - sconto) / 100).round(2)
  end


  def calc_sconto
    libro.prezzo_copertina
  end


  def calc_importo
    calc_prezzo * quantita
  end


  def set_default_conditions
    
    if appunto && libro

      cliente_tipo = appunto.cliente.cliente_tipo
      settore = libro.settore

      if cliente_tipo == "Cartolibreria"      
        self.prezzo_unitario  = libro.prezzo_copertina
        if settore == "Scolastico"
          self.sconto = 18
        else
          self.sconto = 20
        end
      elsif cliente_tipo == "Comune" && settore == "Scolastico"
        self.prezzo_unitario = libro.prezzo_copertina
        self.sconto = 0.25
      else  
        self.prezzo_unitario  = libro.prezzo_consigliato
        self.sconto = 0
      end 
    end

    puts "#{prezzo_unitario} ----"
    puts sconto

  end

end
