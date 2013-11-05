//
//  ViewController.m
//  AESTextEncryption
//
//  Created by Evgenii Neumerzhitckii on 5/11/2013.
//  Copyright (c) 2013 Evgenii Neumerzhitckii. All rights reserved.
//

#import "ViewController.h"

#define TEXT_PLACEHOLDER @"Enter text here. It will be encrypted and copied.\n\nTo decrypt: copy encrypted text from another app and it will be decrypted here. \n\nEncryption type: AES  with 256-bit key."

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *keyText;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottomDistance;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addTopBorder:self.keyText];
    [self registerKeyboardNorifications];
    [self.keyText setValue: [self placeholderColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self setTextPlaceholder];
}

- (void)registerKeyboardNorifications
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

- (void)addTopBorder: (UIView *) view
{
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(0.0f, view.frame.size.height - 1, view.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [view.layer addSublayer:border];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.textView resignFirstResponder];
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
    [self setTextPlaceholder];
    [textView resignFirstResponder];
}

- (void)setTextPlaceholder
{
    if ([self.textView.text isEqualToString:@""]) {
        self.textView.text = TEXT_PLACEHOLDER;
        self.textView.textColor = [self placeholderColor];
    }
}

- (UIColor*)placeholderColor
{
    return [UIColor colorWithRed:120.0/255.0 green:116.0/255.0 blue:115.0/255.0 alpha:1.0];
}

@end
