class AppuntiControllerStylesheet < ApplicationStylesheet

  include AppuntoCellStylesheet

  def table_view(st)
    st.background_color = color.white
  end

end
