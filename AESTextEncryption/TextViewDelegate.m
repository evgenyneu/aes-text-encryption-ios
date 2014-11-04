//
//  TextViewDelegate.m
//  AESTextEncryption
//
//  Created by Evgenii Neumerzhitckii on 10/11/2013.
//  Copyright (c) 2013 Evgenii Neumerzhitckii. All rights reserved.
//

#import "TextViewDelegate.h"
#import "AESEncryptor.h"

#define TEXT_PLACEHOLDER @"Message"

@interface TextViewDelegate ()

@property (weak, nonatomic) ViewController *vc;

@end


@implementation TextViewDelegate

+ (UIColor*) placeholderColor {
  return [UIColor colorWithRed:120.0/255.0 green:116.0/255.0 blue:115.0/255.0 alpha:1.0];
}

+ (NSString*) text:(NSString *)text {
  if ([text isEqualToString: TEXT_PLACEHOLDER]) return @"";
  return [AESEncryptor strip:text];
}

+ (void) setText:(NSString *) text forTextView:(UITextView *) textView {
  textView.text = text;
  textView.textColor = [UIColor blackColor];
}

- (id) initWithVC: (ViewController*) vc {
  self = [super init];
  if( !self ) return nil;

  self.vc = vc;

  return self;
}

- (void)textViewDidChange:(UITextView *)textView
{
  [self.vc showEncryptButton];
}

- (void)setTextPlaceholder: (UITextView *)textView
{
  if ([textView.text isEqualToString:@""]) {
    textView.text = TEXT_PLACEHOLDER;
    textView.textColor = [TextViewDelegate placeholderColor];
  }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
  if ([textView.text isEqualToString:TEXT_PLACEHOLDER]) {
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
  }
  [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
  [self setTextPlaceholder: textView];
  [textView resignFirstResponder];
}

@end
