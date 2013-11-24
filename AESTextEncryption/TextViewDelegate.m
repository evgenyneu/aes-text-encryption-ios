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

//#define TEXT_PLACEHOLDER @"Enter text here. It will be encrypted and copied.\n\nTo decrypt: copy encrypted text from another app and it will be decrypted here. \n\nAES encrypton with 256-bit key is used."

@interface TextViewDelegate ()

@property (weak, nonatomic) ViewController *vc;

@end


@implementation TextViewDelegate

+ (UIColor*) placeholderColor {
  return [UIColor colorWithRed:120.0/255.0 green:116.0/255.0 blue:115.0/255.0 alpha:1.0];
}

+ (NSString*) text:(NSString *)text {
  if ([text isEqualToString: TEXT_PLACEHOLDER]) return @"";
  return text;
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
  [self.vc encrypt];
  [self fixIOS7TextViewBug:textView];
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

// http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string
- (void)fixIOS7TextViewBug:(UITextView *)textView {
  CGRect line = [textView caretRectForPosition:
                 textView.selectedTextRange.start];
  CGFloat overflow = line.origin.y + line.size.height
  - ( textView.contentOffset.y + textView.bounds.size.height
     - textView.contentInset.bottom - textView.contentInset.top );
  if ( overflow > 0 ) {
    // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
    // Scroll caret to visible area
    CGPoint offset = textView.contentOffset;
    offset.y += overflow + 7; // leave 7 pixels margin
    // Cannot animate with setContentOffset:animated: or caret will not appear
    [UIView animateWithDuration:.2 animations:^{
      [textView setContentOffset:offset];
    }];
  }
}

@end
