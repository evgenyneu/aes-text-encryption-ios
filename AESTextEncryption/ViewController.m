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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *keyText;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottomDistance;

@property (strong, nonatomic) TextViewDelegate *textViewDelegate;
@property (weak, nonatomic) IBOutlet UIView *decryptView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *decryptViewHeightConstraint;

@property (strong, nonatomic) NSString *textToDecrypt;
@property (strong, nonatomic) NSString *decryptedText;
@property (weak, nonatomic) IBOutlet UIButton *decryptButton;

@property (strong, nonatomic) AESEncryptor* encryptor;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *encryptButton;

@property (strong, nonatomic) UIBarButtonItem *doneButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.textView.delegate = self.textViewDelegate;
  [self.textViewDelegate setTextPlaceholder: self.textView];

  [self registerKeyboardNotifications];
  [self registerActiveNotification];
  [self.keyText setValue: [TextViewDelegate placeholderColor] forKeyPath:@"_placeholderLabel.textColor"];

  self.decryptView.clipsToBounds = true;
  self.decryptViewHeightConstraint.constant = 0;
  [self setTitleImage];
  [self updateEncryptButton];
}

- (void) toggleEncryptButton: (BOOL) show {
  if (show) {
    self.navigationItem.rightBarButtonItem = self.encryptButton;
  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }
}

- (void) setTitleImage {
  UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"title.png"]];
  self.navigationItem.titleView = imageView;
}

- (AESEncryptor *) encryptor {
  if (!_encryptor) _encryptor = [[AESEncryptor alloc] init];
  return _encryptor;
}

- (NSString *) encrypt
{
  NSString *encrypted = [self.encryptor encrypt:[self messageStripped] withKey:self.keyText.text];
  if (![self.encryptor isEncrypted: encrypted]) return nil;
  return encrypted;
}

- (void) decrypt
{
  if (!self.textToDecrypt) {
    self.decryptedText = nil;
    return;
  }

  NSString *decrypted = [self.encryptor decrypt:self.textToDecrypt withKey:self.keyText.text];
  if (decrypted.length == 0) {
    self.decryptedText = nil;
    return;
  }
  self.decryptedText = decrypted;
}

- (NSString *) keyTextStripped {
  return [AESEncryptor strip: self.keyText.text];
}

- (NSString *) messageStripped {
  return [TextViewDelegate text:self.textView.text];
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
                 name:UIKeyboardWillShowNotification
               object:nil];

  [center addObserver:self
             selector:@selector(handleKeyboardHide:)
                 name:UIKeyboardWillHideNotification
               object:nil];
}

- (void) registerActiveNotification{
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  [center addObserver:self
             selector:@selector(handleBecomeActive:)
                 name:UIApplicationDidBecomeActiveNotification
               object:nil];
}

- (void)handleBecomeActive:(NSNotification *)notification
{
  [self getTextToDecryptFromPasteboard];
  [self decrypt];
  [self updateDecryptedView];
}

- (void)handleKeyboardShow:(NSNotification *)notification
{
  CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  rect = [self.view convertRect:rect fromView:nil]; // to handle orintation
  CGFloat height = rect.size.height;
  self.textBottomDistance.constant = height + 10;
}

- (void)handleKeyboardHide:(NSNotification *)notification
{
  self.textBottomDistance.constant = 10;
}

- (void) updateDecryptedView {
  BOOL decryptedViewVisible = false;
  if (self.decryptedText && ![self.decryptedText isEqualToString:[self messageStripped]]) {
    decryptedViewVisible = true;
  }

  [self toggleDecryptView:decryptedViewVisible];
  NSString *decryptButtonTitle = self.decryptedText;
  if (decryptButtonTitle.length > 100) {
    decryptButtonTitle = [decryptButtonTitle substringToIndex:100];
  }

  [self.decryptButton setTitle:decryptButtonTitle forState:UIControlStateNormal];
}

- (void) toggleDecryptView: (BOOL) isShowing {
  int height = 0;
  if (isShowing) height = 40;
  if (self.decryptViewHeightConstraint.constant == height) return;
  self.decryptViewHeightConstraint.constant = height;
  [UIView animateWithDuration:0.3 animations:^{[self.view layoutIfNeeded];}];
}

- (IBAction)keyTextEditingChanged:(id)sender {
  [self updateEncryptButton];
  [self decrypt];
  [self updateDecryptedView];
}

- (void) getTextToDecryptFromPasteboard {
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  if (![self.encryptor isEncrypted: pasteboard.string]) return;
  self.textToDecrypt = pasteboard.string;
}

- (IBAction)viewDecryptedTextButtonClicked {
  if (!self.decryptedText || self.decryptedText.length == 0) return;
  [TextViewDelegate setText:self.decryptedText forTextView:self.textView];
  [self updateDecryptedView];
}

- (BOOL) isReadyToEncrypt {
  if ([self keyTextStripped].length == 0) return NO;
  if ([self messageStripped].length == 0) return NO;
  return YES;
}

- (void) updateEncryptButton {
  [self toggleEncryptButton:[self isReadyToEncrypt]];
}

- (IBAction)encryptClicked:(UIBarButtonItem *)sender {
  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  [spinner startAnimating];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

  dispatch_queue_t encryptionQueue = dispatch_queue_create("encryption queue", NULL);
  dispatch_async(encryptionQueue, ^{
    NSString *encrypted = [self encrypt];
    dispatch_async(dispatch_get_main_queue(), ^{
      if (encrypted) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = encrypted;
      }
      [self showEncryptedMessage];
    });
  });
}

- (UIBarButtonItem *) doneButton {
  if (!_doneButton) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Copied✓" forState:UIControlStateNormal];
    [button sizeToFit];
    _doneButton = [[UIBarButtonItem alloc] initWithCustomView:button];
  }
  return _doneButton;
}

- (void) showEncryptedMessage {
  self.navigationItem.rightBarButtonItem = self.doneButton;
}


@end
