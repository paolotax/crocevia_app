
schema "0001 initial" do

  entity "Cliente" do
    
    integer32 :remote_id
    string :nome
    string :comune
    string :frazione
    string :cliente_tipo
    string :indirizzo
    string :cap
    string :provincia
    string :telefono
    string :email
    double :latitude
    double :longitude
    string :ragione_sociale
    string :codice_fiscale
    string :partita_iva
    integer16 :appunti_da_fare
    integer16 :appunti_in_sospeso
    boolean :nel_baule
    boolean :fatto
    string :provincia_e_comune, transient: true
    string :uuid
    datetime :created_at
    datetime :updated_at
    datetime :deleted_at

    has_many :appunti, inverse: "Appunto.cliente" 

  end

  entity "Appunto" do

    integer32 :remote_id
    integer32 :cliente_id
    string :status
    string :cliente_nome
    string :destinatario
    string :note
    string :telefono
    string :email
    datetime :created_at
    datetime :updated_at
    datetime :deleted_at
    integer32 :totale_copie
    integer32 :totale_importo
    string :data
    string :note_e_righe, transient: true
    string :uuid

    belongs_to :cliente, inverse: "Cliente.appunti"
    has_many :righe, inverse: "Riga.appunto"

  end

  entity "Riga" do

    integer32 :remote_id
    integer32 :appunto_id
    integer32 :libro_id
    integer32 :fattura_id
    integer16 :quantita
    decimal :prezzo_unitario
    decimal :sconto
    decimal :importo
    string :riga_uuid

    belongs_to :appunto, inverse: "Appunto.righe"
    belongs_to :libro, inverse: "Libro.libro_righe"
  end

  entity "Libro" do

    integer32 :remote_id
    string :titolo
    string :sigla
    string :ean
    string :cm
    string :settore
    string :image_url
    decimal :prezzo_copertina
    decimal :prezzo_consigliato
    datetime :created_at
    datetime :updated_at
    datetime :deleted_at

    has_many :libro_righe, inverse: "Riga.libro"

  end
 
end
