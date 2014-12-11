//
//  DSPAuthenticationTVC.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 12/10/14.
//
//

#import "DSPAuthenticationTVC.h"
#import <RedditKit/RedditKit.h>
#import <SSKeychain/SSKeychain.h>

@interface DSPAuthenticationTVC () <UITextFieldDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *createAccountButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation DSPAuthenticationTVC

+ (void)loginWithKeychainWithCompletion:(LoginSuccessBlock)completion
{
    NSDictionary *account = [[SSKeychain accountsForService:@"DissociatedPress"] firstObject];
    NSString *username = account[@"acct"];
    NSString *password = [SSKeychain passwordForService:@"DissociatedPress" account:username error:nil];
    [DSPAuthenticationTVC signInWithUsername:username password:password completion:completion];
}

+ (void)signInWithUsername:(NSString *)username password:(NSString *)password completion:(LoginSuccessBlock)completion
{
    [[RKClient sharedClient] signInWithUsername:username password:password completion:^(NSError *error) {
        if (error)
        {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                                     message:error.localizedFailureReason
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
            [errorAlertView show];
        }
        else
        {
            for (NSString *account in [SSKeychain accountsForService:@"DissociatedPress"]) {
                [SSKeychain deletePasswordForService:@"DissociatedPress" account:account error:nil];
            }
            [SSKeychain setPassword:password forService:@"DissociatedPress" account:username error:nil];
        }
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    }];
}

- (NSDictionary *)account
{
    NSDictionary *account = [[SSKeychain accountsForService:@"DissociatedPress"] firstObject];
    return account;
}

- (UITextField *)usernameTextField
{
    if (!_usernameTextField) {
        UITextField *usernameTextField = [[UITextField alloc] init];
        usernameTextField.delegate = self;
        usernameTextField.placeholder = @"Username";
        usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
        usernameTextField.backgroundColor = [UIColor whiteColor];
        usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        usernameTextField.borderStyle = UITextBorderStyleBezel;
        [usernameTextField addTarget:self action:@selector(updateDoneButtonStatus) forControlEvents:UIControlEventEditingChanged];
        
        NSString *username = [self account][@"acct"];
        if ([username length] > 0) {
            usernameTextField.text = username;
        }
        
        _usernameTextField = usernameTextField;
    }
    return _usernameTextField;
}

- (UITextField *)passwordTextField
{
    if (!_passwordTextField) {
        UITextField *passwordTextField = [[UITextField alloc] init];
        passwordTextField.delegate = self;
        passwordTextField.placeholder = @"Password";
        passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        passwordTextField.backgroundColor = [UIColor whiteColor];
        passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        passwordTextField.secureTextEntry = YES;
        passwordTextField.borderStyle = UITextBorderStyleBezel;
        [passwordTextField addTarget:self action:@selector(updateDoneButtonStatus) forControlEvents:UIControlEventEditingChanged];
        
        NSString *password = [SSKeychain passwordForService:@"DissociatedPress" account:([self account][@"acct"]) error:nil];
        if ([password length] > 0) {
            passwordTextField.text = password;
        }
        
        _passwordTextField = passwordTextField;
    }
    return _passwordTextField;
}

- (UIButton *)createAccountButton
{
    if (!_createAccountButton) {
        UIButton *createAccountButton = [[UIButton alloc] init];
        [createAccountButton setTitle:@"Create a reddit account" forState:UIControlStateNormal];
        [createAccountButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        createAccountButton.backgroundColor = [UIColor groupTableViewBackgroundColor];
        createAccountButton.translatesAutoresizingMaskIntoConstraints = NO;
        [createAccountButton addTarget:self action:@selector(didPressCreateAccountButton) forControlEvents:UIControlEventTouchUpInside];
        _createAccountButton = createAccountButton;
    }
    return _createAccountButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.title = @"Sign in to reddit";
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
    
    [self updateDoneButtonStatus];
}

- (void)done
{
    if (self.usernameTextField.text.length <= 0 || self.passwordTextField.text.length <= 0) {
        return;
    }
    
    [self.activityIndicator startAnimating];
    __weak __typeof(self)weakSelf = self;
    [DSPAuthenticationTVC signInWithUsername:self.usernameTextField.text password:self.passwordTextField.text completion:^{
        [weakSelf.activityIndicator stopAnimating];
        
        if ([[RKClient sharedClient] isSignedIn]) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}



- (void)updateDoneButtonStatus
{
    if (self.usernameTextField.text.length <= 0 || self.passwordTextField.text.length <= 0) {
        self.doneButton.enabled = NO;
    } else {
        self.doneButton.enabled = YES;
    }
}

- (void)didPressCreateAccountButton
{
    UIAlertView *createAccountAlert = [[UIAlertView alloc] initWithTitle:@"Create reddit account"
                                                                 message:@"Open reddit.com in Safari?"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                       otherButtonTitles:@"Open Safari", nil];
    
    [createAccountAlert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellReuseIdentifier = @"signInCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    if (indexPath.row == 0) {
        [cell.contentView addSubview:self.usernameTextField];
        [self pinView:self.usernameTextField toSuperview:cell.contentView];
    } else if (indexPath.row == 1) {
        [cell.contentView addSubview:self.passwordTextField];
        [self pinView:self.passwordTextField toSuperview:cell.contentView];
    } else if (indexPath.row == 2) {
        [cell.contentView addSubview:self.createAccountButton];
        [self pinView:self.createAccountButton toSuperview:cell.contentView];
    }
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)pinView:(UIView *)view toSuperview:(UIView *)superview
{
    //    [superview removeConstraints:superview.constraints];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superview
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:8]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superview
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:8]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:superview
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:8]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:superview
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:8]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self done];
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Create reddit account"]) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.reddit.com/login"]];
        }
    }
}

@end
