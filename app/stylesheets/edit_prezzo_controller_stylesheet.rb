class EditPrezzoControllerStylesheet < ApplicationStylesheet
  

  def root_view(st)
    st.background_color = color.white
  end


  def edit_prezzo(st)
    st.frame = {l:205, t: 7, w: 100, h: 30}
    st.view.delegate = self
    st.view.borderStyle = UITextBorderStyleRoundedRect
    st.view.keyboardType = UIKeyboardTypeDecimalPad 
    st.view.textAlignment = UITextAlignmentRight
    
  end


  def edit_sconto(st)
    st.frame = {l:205, t: 7, w: 100, h: 30}
    st.view.delegate = self
    st.view.borderStyle = UITextBorderStyleRoundedRect
    st.view.keyboardType = UIKeyboardTypeDecimalPad 
    st.view.textAlignment = UITextAlignmentRight
  end

end