
BASE_URL = "http://youpropa.com"
#BASE_URL = "http://youpropa.dev"

#server 
APP_ID = "36e1b9ed802dc7ee45e375bf318924dc3ae0f0f842c690611fde8336687960eb"
SECRET = "11ab577f8fabf2ac33bdd75e951fc6507ef7bc21ef993c2a77a1383bed438224"


TextFieldTypeDecimal     = 0
TextFieldTypeLongString  = 1
TextFieldTypeString      = 2
TextFieldTypeEmail       = 3
TextFieldTypePhone       = 4
TextFieldTypeCapitalize  = 5


SettoriList = ["Scolastico", "Parascolastico", "Vacanze", "Varia", "Eventuale", "Guide", "Adozionale", "Concorrenza", "Scorrimento"]

TIPI_CLIENTI = ['Scuola Primaria', 'Istituto Comprensivo', 'Direzione Didattica', 'Cartolibreria', 'Persona Fisica', 'Ditta', 'Comune']

ABBR_TIPI    = ['E', 'IC', 'D', 'C', '', '', 'Com']

TABLES = ["clienti", "appunti", "righe", "classi", "libri", "adozioni"]

STATUSES = ["da fare", "in sospeso", "preparato", "completato"]

FILTRI = ["nel baule", "da fare", "in sospeso", "tutti"]
  

  COLORS = [
    "#ff7f00".uicolor,
    "#5ad535".uicolor,
    "#f80e57".uicolor,
    "#259cf3".uicolor,
    "#BD10E0".uicolor
  ]
  
# COLORS = [
#   "#F5A523".uicolor,
#   "#7DD320".uicolor,
#   "#D50820".uicolor,
#   "#3E94E0".uicolor
# ]

MENU_IMAGES = [
  "icon-nel_baule",
  "icon-da_fare",
  "icon-in_sospeso",
  "icon-completato",
  "icon-mappa"
]