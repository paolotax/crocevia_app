class EditTextViewControllerStylesheet < ApplicationStylesheet
  

  def root_view(st)
    st.background_color = color.white
  end


  def text_view(st)
    st.frame = {t: 0, w: 320, h: 568}
    st.view.font = font.large
  end
end
