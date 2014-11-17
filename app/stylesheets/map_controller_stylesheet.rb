class MapControllerStylesheet < ApplicationStylesheet
  # Add your view stylesheets here. You can then override styles if needed, example:
  # include FooStylesheet

  def setup
    # Add stylesheet specific setup stuff here.
    # Add application specific setup stuff in application_stylesheet.rb
  end

  def root_view(st)
    st.background_color = color.white
  end


  def search_bar(st)
    #st.frame = {t: 0, w: 320, h: 44}
    st.view.placeholder = "Cerca libro"
    #st.view.backgroundImage = UIImage.new
    #st.view.translucent = true   
  end


  def map(st)

  end

end
