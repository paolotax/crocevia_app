class Cliente < CDQManagedObject

  scope :per_provincia, sort_by(:provincia).sort_by(:comune).sort_by(:remote_id)
  
  scope :tutti,      per_provincia     
  scope :nel_baule,  where(nel_baule: true)
  scope :in_sospeso, where(appunti_da_fare: nil).and(:appunti_in_sospeso).ne(0)
  scope :da_fare,    where(:appunti_da_fare).ne(0)


  def citta
    (self.frazione.nil? || self.frazione == "") ? self.comune : self.frazione
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
    if nel_baule == 1
      self.nel_baule = 0
    else
      self.nel_baule = 1
    end
  end
  
end
