class LoginController < UIViewController

  attr_accessor :username, :password

  def viewDidLoad
    super

    rmq.stylesheet = LoginControllerStylesheet
    rmq(self.view).apply_style :root_view

    # Create your views here
    rmq.append(UIImageView, :logo_black)
    
    @table_view = rmq.append(UITableView.grouped, :table_view).get
    @table_view.delegate = self
    @table_view.dataSource = self

  end


  def viewWillAppear(animated)
    super
    "TSMessageNotification".add_observer(self, "show_message:", nil )
  end

  
  def viewWillDisappear(animated)
    super
    "TSMessageNotification".remove_observer(self, nil)
  end


#pragma mark - Actions


  def show_message(notification)
    message = notification.userInfo[:message]
    
    TSMessage.showNotificationInViewController self,
                                   title:message[:title],
                                subtitle:message[:subtitle],
                                    type:TSMessageNotificationTypeError,
                                duration:TSMessageNotificationDurationAutomatic,
                                callback:nil,
                             buttonTitle:nil,
                          buttonCallback:nil,
                              atPosition:TSMessageNotificationPositionTop,
                     canBeDismisedByUser:true
  end


#pragma mark - tableViewDelegates


  def tableView(tableView, numberOfRowsInSection: section)
    3
  end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)

    @menuIdentifier ||= "menu_cell"
    cell = tableView.dequeueReusableCellWithIdentifier(@menuIdentifier) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@menuIdentifier)
    end

    if indexPath.row == 0
      
      @username_field = rmq(cell.contentView).append(UITextField, :username_field).get
      @username_field.text = CredentialStore.default.username
      
    elsif indexPath.row == 1
      
      @password_field = rmq(cell.contentView).append(UITextField, :password_field).get
      @password_field.text = CredentialStore.default.password
    
    elsif indexPath.row == 2
      
      submit_button = rmq(cell.contentView).append(UIButton.rounded, :submit_button).on(:tap) do
        dismiss = lambda do
          self.dismissViewControllerAnimated true, completion:nil
        end
        UserAuthenticator.shared.loginWithUsername(@username_field.text, password:@password_field.text, success:dismiss, failure:nil)
      end
        
    end
        
    cell.selectionStyle = UITableViewCellSelectionStyleNone
    cell
  end


  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if indexPath.row == 2
      60
    else
      40
    end
  end


end
