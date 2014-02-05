class ClientiControllerStylesheet < ApplicationStylesheet
  # Add your view stylesheets here. You can then override styles if needed, example:
  include ClienteCellStylesheet

  def setup
    # Add sytlesheet specific setup stuff here.
    # Add application specific setup stuff in application_stylesheet.rb
  end

  def root_view(st)
    st.background_color = color.white
  end


end
