module AppuntiCollectionCellStylesheet
 
  def cell_size
    {w: 300, h: 300}
  end

  
  def appunti_cell(st)
    st.frame = cell_size
    st.background_color = color.white
    st.view.layer.cornerRadius = 10
    # Style overall view here
  end


  def cliente_nome(st)
    st.frame = {l: 10, t:10, w:280, h:25}
    #st.background_color = color.random
    st.font = font.large
  end


  def destinatario(st)
    st.frame = {l: 10, t:34, w:280, h:25}
    #st.background_color = color.random
    st.font = font.medium
  end


  def note(st)
    st.frame = {l: 10, t:60, w:280, h:160}
    st.background_color = color.clear
    st.view.editable = false
    st.view.userInteractionEnabled = true
    st.view.font = font.medium
  end


  def image_status(st)
    st.frame = {l: 56, t:252, w:38, h:38}
  end

  
  def image_baule(st)
    st.frame = {l: 10, t:252, w:38, h:38}
  end


  def image_cloud(st)
    st.frame = {l: 10, t:20, w:280, h:25}
  end


end