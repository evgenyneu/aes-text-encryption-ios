//
//  ViewController.m
//  AESTextEncryption
//
//  Created by Evgenii Neumerzhitckii on 5/11/2013.
//  Copyright (c) 2013 Evgenii Neumerzhitckii. All rights reserved.
//

#import "ViewController.h"
#import "AESEncryptor.h"
#import "TextViewDelegate.h"
#import "constants.h"
#import "SoundPlayer.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottomDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordTopMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTopMarginConstraint;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) NSLayoutConstraint *toolbarZeroHeightConstraint;

@property (strong, nonatomic) TextViewDelegate *textViewDelegate;

@property (strong, nonatomic) AESEncryptor* encryptor;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *encryptButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *decryptBarButton;

@property (strong, nonatomic) UIBarButtonItem *doneButton;

@property (strong, nonatomic) NSTimer* decryptSpinnerTimer;
@property (strong, nonatomic) NSTimer* encryptSpinnerTimer;

@property (nonatomic, strong) iiSoundPlayer *tickPlayer;
@property (nonatomic, strong) iiSoundPlayer *errorPlayer;


@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.messageTextView.delegate = self.textViewDelegate;
  [self.textViewDelegate setTextPlaceholder: self.messageTextView];

  [self registerKeyboardNotifications];
  [self.passwordTextField setValue: [TextViewDelegate placeholderColor] forKeyPath:@"_placeholderLabel.textColor"];

  [self showToolbar];
  [self setTitleImage];

  [self.messageTextView setTextContainerInset:UIEdgeInsetsMake(3, 0, 0, 0)];

  self.tickPlayer = [[iiSoundPlayer alloc] initWithSoundName:@"tick.wav"];
  [self.tickPlayer prepareToPlay];

  self.errorPlayer = [[iiSoundPlayer alloc] initWithSoundName:@"twitch.wav"];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self toggleCompactLayout:self.view.bounds.size.height];
  [self toggleToolbarVisibility:self.view.bounds.size.height];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  [self toggleCompactLayout:size.height];
  [self toggleToolbarVisibility:size.height];
  [self fixTextViewContentOffsetBug];
}

// DEPRECATED in iOS 8: Remove this method when iOS7 support is dropped
// viewWillTransitionToSize is replacing it in iOS 8.
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

  CGFloat screenHeight = MIN(self.view.bounds.size.width,self.view.bounds.size.height);

  if UIInterfaceOrientationIsPortrait(toInterfaceOrientation) {
    screenHeight = MAX(self.view.bounds.size.width,self.view.bounds.size.height);
  }

  [self toggleCompactLayout:screenHeight];
  [self toggleToolbarVisibility:screenHeight];
}

- (void) setTitleImage {
  UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"title.png"]];
  self.navigationItem.titleView = imageView;
}

- (AESEncryptor *) encryptor {
  if (!_encryptor) _encryptor = [[AESEncryptor alloc] init];
  return _encryptor;
}

- (NSString *) keyTextStripped {
  return [AESEncryptor strip: self.passwordTextField.text];
}

- (NSString *) messageStripped {
  return [TextViewDelegate text:self.messageTextView.text];
}

- (void)setMessage: (NSString*)text
{
  [TextViewDelegate setText:text forTextView:self.messageTextView];
}

- (TextViewDelegate *) textViewDelegate {
  if (!_textViewDelegate) {
    _textViewDelegate = [[TextViewDelegate alloc] initWithVC:self];
  }
  return _textViewDelegate;
}

- (void)registerKeyboardNotifications
{
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  [center addObserver:self
             selector:@selector(handleKeyboardShow:)
                 name:UIKeyboardDidShowNotification
               object:nil];

  [center addObserver:self
             selector:@selector(handleKeyboardHide:)
                 name:UIKeyboardWillHideNotification
               object:nil];
}

- (void)handleKeyboardShow:(NSNotification *)notification
{
  CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  rect = [self.view convertRect:rect fromView:nil]; // to handle orintation
  CGFloat height = rect.size.height;
  self.textBottomDistance.constant = height;

  [self fixTextViewContentOffsetBug];
}

// Fix bug, when a blank inset appears on top, when cursor is at beginning of text view
// and it changes orientation to landscape
- (void)fixTextViewContentOffsetBug {
  if (self.messageTextView.contentOffset.y < 0) {
    self.messageTextView.contentOffset = CGPointMake(self.messageTextView.contentOffset.x, 0);
  }
}

- (void)handleKeyboardHide:(NSNotification *)notification
{
  self.textBottomDistance.constant = 0;
}

- (IBAction)onPasswordChanged:(id)sender {
  [self showEncryptButton];
}

#pragma mark - Sounds

- (void)playTick {
  [self.tickPlayer playAsyncAtVolume:0.2];
}

- (void)playError {
  [self.errorPlayer playAsyncAtVolume:0.5];
}

#pragma mark - Compact layout

- (void)toggleCompactLayout:(CGFloat)screenHeight {
  if (screenHeight < aesCompactHeight) {
    self.passwordHeightConstraint.constant = aesPasswordHeightMargin_compact;
    self.passwordTopMarginConstraint.constant = aesPasswordTopMargin_compact;
    self.messageTopMarginConstraint.constant = aesMessageTopMargin_compact;
  } else {
    self.passwordHeightConstraint.constant = aesPasswordHeightMargin;
    self.passwordTopMarginConstraint.constant = aesPasswordTopMargin;
    self.messageTopMarginConstraint.constant = aesMessageTopMargin;
  }
}

#pragma mark - Toolbar

- (void)hideToolbar {
  if (!self.toolbarZeroHeightConstraint) {
    self.toolbarZeroHeightConstraint = [NSLayoutConstraint constraintWithItem:self.toolbar
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:1
                                                                     constant:0];

    [self.toolbar addConstraint:self.toolbarZeroHeightConstraint];
  }

  self.toolbar.hidden = true;
}

- (void)showToolbar {
  if (self.toolbarZeroHeightConstraint) {
    [self.toolbar removeConstraint:self.toolbarZeroHeightConstraint];
    self.toolbarZeroHeightConstraint = nil;
  }
  self.toolbar.hidden = false;
}

- (void)toggleToolbarVisibility:(CGFloat)screenHeight {
  if (screenHeight < 450) {
    [self hideToolbar];
  } else {
    [self showToolbar];
  }
}

- (IBAction)onCopyTapped:(id)sender {
  [self playTick];
  if ([self messageStripped].length == 0) { return; }
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  pasteboard.string = [self messageStripped];
}

- (IBAction)onPasteTapped:(id)sender {
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  [self setMessage: pasteboard.string];
  [self showEncryptButton];
  [self playTick];
}

- (IBAction)onClearTapped:(id)sender {
  [self setMessage: @""];
  [self showEncryptButton];
  [self playTick];
}

#pragma mark - Encrypt

- (void) showEncryptButton {
  [self invalidateEncryptSpinnerTimer];
  self.navigationItem.rightBarButtonItem = self.encryptButton;
}

- (void) showEncryptionDidFinishMessage {
  [self invalidateEncryptSpinnerTimer];
  self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void) invalidateEncryptSpinnerTimer {
  if (self.encryptSpinnerTimer) {
    [self.encryptSpinnerTimer invalidate];
    self.encryptSpinnerTimer = nil;
  }
}

- (void) showEncryptingSpinner {
  self.encryptSpinnerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                              target:self
                                                            selector:@selector(onShowEncryptSpinnerTimer:)
                                                            userInfo:nil
                                                             repeats:NO];
}

- (void) onShowEncryptSpinnerTimer:(NSTimer*)timer {
  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  [spinner startAnimating];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (IBAction)encryptClicked:(UIBarButtonItem *)sender {
  [self showEncryptingSpinner];

  dispatch_queue_t encryptionQueue = dispatch_queue_create("encryption queue", NULL);
  dispatch_async(encryptionQueue, ^{
    NSString *encrypted = [self encrypt];
    dispatch_async(dispatch_get_main_queue(), ^{
      if (encrypted) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = encrypted;
        [self setMessage:encrypted];
        [self showEncryptionDidFinishMessage];
        [self playTick];
      } else {
        [self playError];
        [self showEncryptButton];
      }
    });
  });
}

- (NSString *) encrypt
{
  NSString *encrypted = [self.encryptor encrypt:[self messageStripped] withKey:[self keyTextStripped]];
  if (![self.encryptor isEncrypted: encrypted]) return nil;
  return encrypted;
}

- (UIBarButtonItem *) doneButton {
  if (!_doneButton) {
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Copied✓"
                                                   style:UIBarButtonItemStylePlain
                                                  target:self action:@selector(encryptClicked:)];
  }
  return _doneButton;
}

#pragma mark - Decrypt

- (void) showDecryptButton {
  if (self.decryptSpinnerTimer) {
    [self.decryptSpinnerTimer invalidate];
    self.decryptSpinnerTimer = nil;
  }

  self.navigationItem.leftBarButtonItem = self.decryptBarButton;
}

- (void) showDecryptingSpinner {
  self.decryptSpinnerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                       target:self
                                                     selector:@selector(onShowDecryptSpinnerTimer:)
                                                     userInfo:nil
                                                      repeats:NO];

}

- (void) onShowDecryptSpinnerTimer:(NSTimer*)timer {
  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  [spinner startAnimating];
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (IBAction)decryptClicked:(UIBarButtonItem *)sender {
  [self decryptAndUpdate];
}

- (BOOL) isReadyToDecrypt {
  if ([self keyTextStripped].length == 0) return NO;
  if ([self messageStripped].length == 0) return NO;
  if (![self.encryptor isEncrypted: [self messageStripped]]) return NO;
  return YES;
}

- (void) decryptAndUpdate {
  if (![self isReadyToDecrypt]) {
    [self playError];
    return;
  }

  [self showDecryptingSpinner];

  dispatch_queue_t decryptQueue = dispatch_queue_create("descryption queue", NULL);
  dispatch_async(decryptQueue, ^{
    NSString *decrypted = [self decrypt];
    dispatch_async(dispatch_get_main_queue(), ^{
      if (decrypted && decrypted.length > 0) {
        [self setMessage:decrypted];
        [self playTick];
      } else {
        [self playError];
      }

      [self showDecryptButton];
      [self showEncryptButton];
    });
  });
}

- (NSString*) decrypt
{
  if (![self messageStripped]) return nil;
  return [self.encryptor decrypt:[self messageStripped] withKey:[self keyTextStripped]];
}

@end
