class Cliente < CDQManagedObject

  scope :per_provincia, sort_by(:provincia).sort_by(:comune).sort_by(:remote_id)
  
  scope :tutti,      per_provincia     
  scope :nel_baule,  where(nel_baule: true)
  scope :in_sospeso, where(appunti_da_fare: nil).and(:appunti_in_sospeso).ne(0)
  scope :da_fare,    where(:appunti_da_fare).ne(0)
  
  # scope :nearest,    lambda { |lat, lng|  


  def citta
    frazione.blank? ? comune : frazione
  end

  
  # per MKAnnotationView
  def title
    nome
  end

  def self.nearest(lat, lng)
    gap = 0.1
    Cliente.where("latitude > %f", lat - gap).and("latitude < %f", lat + gap ).and("longitude > %f", lng - gap).and("longitude < %f", lng + gap)
  end

  def coordinate
    CLLocationCoordinate2D.new(latitude, longitude)
  end


  def color
    if nel_baule && nel_baule == 1
      color = COLORS[0]
    elsif appunti_da_fare && appunti_da_fare > 0
      color = COLORS[1]
    elsif appunti_in_sospeso && appunti_in_sospeso > 0
      color = COLORS[2]
    else
      color = COLORS[3]
    end
    color
  end


  def toggle_baule
    self.updated_at = Time.now
    if nel_baule == 1
      self.nel_baule = 0
    else
      self.nel_baule = 1
    end
  end


  def valid?
    !nome.blank? && !comune.blank? && !provincia.blank? && !cliente_tipo.blank?
  end


  def mapItem
    
    # addressDict = {
    #   kABPersonAddressCountryKey: "IT",
    #   kABPersonAddressCityKey: "#{frazione} #{comune}",
    #   kABPersonAddressStreetKey: "#{indirizzo}",
    #   kABPersonAddressZIPKey: "#{cap}"
    # }

    placemark = MKPlacemark.alloc.initWithCoordinate(self.coordinate, addressDictionary:nil)
    mapItem = MKMapItem.alloc.initWithPlacemark(placemark)
    mapItem.name = self.title
    mapItem.phoneNumber = "#{telefono}";
    mapItem.url = NSURL.URLWithString("http://youpropa.com/clienti/#{self.ClienteId}")
    mapItem
  end
  
  
end
