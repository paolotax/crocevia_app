class EditTextViewController < UIViewController


  attr_accessor :text_changed_block


  def viewDidLoad
    super

    rmq.stylesheet = EditTextViewControllerStylesheet
    rmq(self.view).apply_style :root_view

    @text_view= rmq.append(UITextView, :text_view).get


    navigationItem.leftBarButtonItem = UIBarButtonItem.cancel do |button|
      cancel(button) 
    end
    navigationItem.rightBarButtonItem = UIBarButtonItem.done do |button|
      done(button)
    end

  end


  def viewWillAppear(animated)
    super
    @text_view.text = @data
    @text_view.becomeFirstResponder
  end

  
  def load_data(data)
    @data = data
  end


#pragma mark - Actions


  def handleTextCompletion

    text = @text_view.text
  
    error = Pointer.new(:object)
    success = @text_changed_block.call(text, error)
    if (success) 
      navigationController.popViewControllerAnimated(true)
      return true
    else
      alertView = UIAlertView.alloc.initWithTitle("Errore", message:error.localizedDescription, delegate:nil, cancelButtonTitle:"Chiudi", otherButtonTitles:nil);
      alertView.show
      return false
    end
  end 


  def done(sender)
    self.handleTextCompletion
  end
  

  def cancel(sender)
    navigationController.popViewControllerAnimated(true)
  end


end

