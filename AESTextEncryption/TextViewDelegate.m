//
//  TextViewDelegate.m
//  AESTextEncryption
//
//  Created by Evgenii Neumerzhitckii on 10/11/2013.
//  Copyright (c) 2013 Evgenii Neumerzhitckii. All rights reserved.
//

#import "TextViewDelegate.h"
#import "AESEncryptor.h"

#define TEXT_PLACEHOLDER @"Enter text here. It will be encrypted and copied.\n\nTo decrypt: copy encrypted text from another app and it will be decrypted here. \n\nAES encrypton with 256-bit key is used."

@interface TextViewDelegate ()

@property (weak, nonatomic) UITextField *keyText;

@end


@implementation TextViewDelegate

+ (UIColor*) placeholderColor {
    return [UIColor colorWithRed:120.0/255.0 green:116.0/255.0 blue:115.0/255.0 alpha:1.0];
}

- (id) initWithKeyText: (UITextField*) keyText {
    self = [super init];
    if( !self ) return nil;
 
    self.keyText = keyText;

    return self;
}

- (void)textViewDidChange:(UITextView *)textView
{
    AESEncryptor *encryptor = [[AESEncryptor alloc] init];
    NSString *encrypted = [encryptor encrypt:textView.text withKey:self.keyText.text];
    NSLog(@"Encrypted text: %@", encrypted);
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
