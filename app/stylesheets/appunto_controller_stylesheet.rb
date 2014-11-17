class AppuntoControllerStylesheet < ApplicationStylesheet
  # Add your view stylesheets here. You can then override styles if needed, example:
  # include FooStylesheet

  def setup
    # Add stylesheet specific setup stuff here.
    # Add application specific setup stuff in application_stylesheet.rb
  end

  def root_view(st)
    #st.background_color = color.red
  end


  def cliente(st)
    st.frame = {l: 10, t: 78, w: 250, h: 30}
    st.font = UIFont.fontWithName("HelveticaNeue-Light", size:24)
    st.color = "#0079FF".uicolor
  end


  def destinatario(st)
    st.frame = {l: 10, t: 112, w: 200, h: 20}
    st.font = font.subhead
  end

  
  def note(st)
    st.frame = {l: 6, t: 135, w: 298, h: 200}
    st.background_color = UIColor.clearColor
    st.font = font.righe
  end


  def print(st)
    st.frame =  {l: 6, t: 490, w: 44, h: 44}
    st.image = image.resource('icon-tag')
  end


  def status(st)
    st.frame =  {l: 263, t: 80, w: 40, h: 40}
    #st.image = image.resource('icon-tag')
  end


  def totale_copie(st)
    st.frame = {l: 170, t: 366, w:134, h:22}
    st.color = color.gray
    st.text_alignment = UITextAlignmentRight
    st.font = UIFont.fontWithName("HelveticaNeue-Light", size:18)
    
  end


  def totale_importo(st)
    st.frame = {l: 170, t: 393, w:134, h:22}
    st.color = color.red
    st.text_alignment = UITextAlignmentRight
    st.font = UIFont.fontWithName("HelveticaNeue-Light", size:18)
    
  end


  def info(st)
    st.frame = { l:10, t: 423, w:130, h:15}
    st.color = color.gray
    st.font = UIFont.fontWithName("HelveticaNeue-Light", size:11)
    
  end


  def created_at(st)
    st.frame = { l:140, t: 423, w:162, h:15}
    st.color = color.gray
    st.font = UIFont.fontWithName("HelveticaNeue-Light", size:11)
    st.text_alignment = UITextAlignmentRight
    
  end

  def updated_at(st)
    st.frame = { l:140, t: 438, w:162, h:15}
    st.color = color.gray
    st.font = UIFont.fontWithName("HelveticaNeue-Light", size:11)
    st.text_alignment = UITextAlignmentRight
    
  end


end
