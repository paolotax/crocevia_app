class Appunto < CDQManagedObject

  scope :a_per_provincia, sort_by("cliente.provincia").sort_by("cliente.comune").sort_by("cliente.remote_id")
  
  scope :a_tutti,      a_per_provincia.where(deleted_at: nil)     
  
  scope :cronologia,   sort_by(:created_at, :descending).where(deleted_at: nil)
  scope :per_localita, sort_by("cliente.provincia").sort_by("cliente.comune").sort_by("cliente.remote_id").sort_by(:remote_id, :descending)
  
  scope :a_nel_baule,  where(deleted_at: nil).and("cliente.nel_baule = true")
  scope :a_in_sospeso, where(deleted_at: nil).and(status: "in_sospeso")
  scope :a_da_fare,    where(deleted_at: nil).and(:status).ne("in_sospeso").and.ne("completato")
  scope :a_completato,    where(deleted_at: nil).and(:status).eq("completato")


  def note_e_righe
    note_e_righe = ""
    unless self.note.nil? || self.note == ""
      note_e_righe += self.note + "\r\n"
    end 
    self.righe.sort_by("libro.titolo").each do |r|
      note_e_righe += "#{r.quantita} - #{r.libro.titolo}\r\n"
    end
    note_e_righe    
  end


  def calc_importo
    importi = [0]
    self.righe.each do |r|
      importi << r.calc_importo.round(2)
    end    
    importi.reduce(:+).round(2)
  end


  def calc_copie
    copie = [0]
    self.righe.each do |r|
      copie << r.quantita
    end    
    copie.reduce(:+)
  end
  
end
