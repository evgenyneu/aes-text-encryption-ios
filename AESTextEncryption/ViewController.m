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

@property (strong, nonatomic) NSString *textToDecrypt;
@property (strong, nonatomic) NSString *decryptedText;

@property (strong, nonatomic) AESEncryptor* encryptor;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *encryptButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *decryptBarButton;

@property (strong, nonatomic) UIBarButtonItem *doneButton;

@property (nonatomic, weak) NSTimer* passwordDecryptTimer;

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

  [self setTitleImage];
  [self updateEncryptButton];
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
  self.textBottomDistance.constant = height + 10;
}

- (void)handleKeyboardHide:(NSNotification *)notification
{
  self.textBottomDistance.constant = 10;
}

#pragma mark - Encrypt

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
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Copied✓" style:UIBarButtonItemStylePlain target:nil action:nil];
  }
  return _doneButton;
}

- (void) showEncryptedMessage {
  self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void) toggleEncryptButton: (BOOL) show {
  if (show) {
    self.navigationItem.rightBarButtonItem = self.encryptButton;
  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }
}

- (NSString *) encrypt
{
  NSString *encrypted = [self.encryptor encrypt:[self messageStripped] withKey:self.keyText.text];
  if (![self.encryptor isEncrypted: encrypted]) return nil;
  return encrypted;
}

#pragma mark - Decrypt

- (void) updateDecryptButton {
  BOOL show = self.decryptedText && ![self.decryptedText isEqualToString:[self messageStripped]];
  [self updateDecryptButtonTitle: self.decryptedText];
  [self toggleDecryptButton:show];
}

- (void) updateDecryptButtonTitle: (NSString*) title {
  if (!title) return;
  if (title.length > 10) {
    title = [title substringToIndex:10];
    title = [title stringByAppendingString:@"..."];
  }
  self.decryptBarButton.title = [@"↓" stringByAppendingString:title];
}

- (void) toggleDecryptButton: (BOOL) show {
  if (show) {
    self.navigationItem.leftBarButtonItem = self.decryptBarButton;
  } else {
    self.navigationItem.leftBarButtonItem = nil;
  }
}

- (IBAction)keyTextEditingChanged:(id)sender {
  [self updateEncryptButton];
  [self decryptAndUpdatedAfterTimeout];
}

- (void) getTextToDecryptFromPasteboard {
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  if (![self.encryptor isEncrypted: pasteboard.string]) return;
  self.textToDecrypt = pasteboard.string;
}

- (IBAction)decryptClicked:(UIBarButtonItem *)sender {
  if (!self.decryptedText || self.decryptedText.length == 0) return;
  [TextViewDelegate setText:self.decryptedText forTextView:self.textView];
  [self updateDecryptButton];
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
  [self decryptAndUpdate];
}

- (NSString*) decrypt
{
  if (!self.textToDecrypt) return nil;
  return [self.encryptor decrypt:self.textToDecrypt withKey:self.keyText.text];
}

- (void) decryptTimerFired:(NSTimer *)timer {
  [self decryptAndUpdate];
}

- (void) decryptAndUpdatedAfterTimeout {
  if (!self.textToDecrypt) return;
  [self.passwordDecryptTimer invalidate];

  self.passwordDecryptTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                               target:self
                                                             selector:@selector(decryptTimerFired:)
                                                             userInfo:nil
                                                              repeats:NO];
}

- (void) showDecryptingSpinner {
  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  [spinner startAnimating];
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void) decryptAndUpdate {
  [self showDecryptingSpinner];

  dispatch_queue_t decryptQueue = dispatch_queue_create("descryption queue", NULL);
  dispatch_async(decryptQueue, ^{
    NSString *decrypted = [self decrypt];
    dispatch_async(dispatch_get_main_queue(), ^{
      if (decrypted && decrypted.length > 0) {
        self.decryptedText = decrypted;
      } else {
        self.decryptedText = nil;
      }
      [self updateDecryptButton];
    });
  });
}

@end
