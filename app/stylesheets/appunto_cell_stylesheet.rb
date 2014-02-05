module AppuntoCellStylesheet
   
  def appunto_cell(st)
    st.frame = {l: 0, t:0, w:320, h:90}
    st.background_color = color.white
  end


  def note(st)
    st.frame = {l: 35, t:0, w:275, h:80}
    st.background_color = color.clear
    st.view.editable = false
    st.view.userInteractionEnabled = false
  end


  def image_status(st)
    st.frame = {l: 10, t:10, w:20, h:20}
  end

  def updated_at(st)
    st.frame = {l: 250, t:10, w:60, h:15}
    st.view.textAlignment = UITextAlignmentRight
    st.font = font.small
    st.background_color = color.clear
  end
  
  def image_baule(st)
    st.frame = {l: 10, t:35, w:20, h:20}
  end


  def image_phone(st)
    st.frame = {l: 10, t:60, w:20, h:20}
    st.view.alpha = 0.5
  end

end

