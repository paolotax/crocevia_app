class AppuntoController < UIViewController

  attr_accessor :appunto, :index

  include PrintDelegate

  def viewDidLoad
    super

    rmq.stylesheet = AppuntoControllerStylesheet
    rmq(self.view).apply_style :root_view

    # Create your views here
    @cliente      = rmq.append(UILabel, :cliente).get
    @destinatario = rmq.append(UILabel, :destinatario).get
    @note         = rmq.append(UITextView, :note).get

    @print = rmq.append(UIButton, :print).on(:touch) do
      print_appunti([appunto.remote_id])
    end.get

    @status = rmq.append(UIButton, :status).on(:touch) do
      print_appunti([appunto.remote_id])
    end.get

    @totale_copie = rmq.append(UILabel, :totale_copie).get
    @totale_importo = rmq.append(UILabel, :totale_importo).get

    @info       = rmq.append(UILabel, :info).get
    @created_at = rmq.append(UILabel, :created_at).get
    @updated_at = rmq.append(UILabel, :updated_at).get
    
    # @info_documento = rmq.append(UILabel, :info_documento).get

    if appunto
      update
    end

  end


  def update
    @cliente.text = appunto.cliente.nome
    @destinatario.text = appunto.destinatario 
    @note.text = appunto.note_e_righe

    if status = appunto.status
      @status.setImage "icon-#{status}-on35".uiimage, forState:UIControlStateNormal
    end

    
    if appunto.calc_copie != 0
      @totale_copie.text = "copie #{appunto.calc_copie}"
      @totale_importo.text = "€ #{appunto.calc_importo}"
    end



    @info.text = "Appunto ##{appunto.remote_id}"
    @created_at.text = "creato il - #{MHPrettyDate.prettyDateFromDate(appunto.created_at, withFormat:MHPrettyDateFormatNoTime)}"
    @updated_at.text = "ultima modifica - #{MHPrettyDate.prettyDateFromDate(appunto.updated_at, withFormat:MHPrettyDateFormatNoTime)}"

    # if fattura = appunto.fattura_id
    #   @info_documento.text = "registrato documento  #{}"
    # end


  end



end

