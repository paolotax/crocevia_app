class LoginControllerStylesheet < ApplicationStylesheet
  

  def root_view(st)
    st.background_color = color.white
  end


  def table_view(st)
    st.frame = {t: 150, w: 320, h: 250}
    st.view.backgroundColor = UIColor.clearColor
    st.view.scrollEnabled = false
  end


  def logo_black(st)
    st.frame = {l: 58, t: 80, w: 205, h: 45}
    st.centered = :horizontal
    st.image = image.resource('youpropa-app-black')
  end


  def password_field(st)
    st.frame = {l:20, t:5, w:280, h:30}
    st.view.placeholder = "password"
    st.view.autocorrectionType = UITextAutocorrectionTypeNo
    st.view.autocapitalizationType = UITextAutocapitalizationTypeNone      
    st.view.clearButtonMode = UITextFieldViewModeWhileEditing
    st.view.secureTextEntry = true        
    st.view.delegate = self
  end


  def username_field(st)
    st.frame = {l:20, t:5, w:280, h:30}
    st.view.placeholder = "nome utente"
    st.view.autocorrectionType = UITextAutocorrectionTypeNo
    st.view.autocapitalizationType = UITextAutocapitalizationTypeNone
    st.view.clearButtonMode = UITextFieldViewModeWhileEditing
    st.view.delegate = self
  end


  def submit_button(st)
    st.frame = {l:20, t:15, w:278, h:30}    
    st.view.setTitle "Accedi", forState:UIControlStateNormal
    st.view.tintColor = color.white
    st.view.layer.cornerRadius = 10
    st.background_color = color.blue
  end


end
