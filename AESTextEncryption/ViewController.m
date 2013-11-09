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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.delegate = self.textViewDelegate;
    [self.textViewDelegate setTextPlaceholder: self.textView];
    
    [self addBorder:self.keyText];
    [self registerKeyboardNorifications];
    [self.keyText setValue: [TextViewDelegate placeholderColor] forKeyPath:@"_placeholderLabel.textColor"];
}

- (TextViewDelegate *) textViewDelegate {
    if (!_textViewDelegate) {
        _textViewDelegate = [[TextViewDelegate alloc] initWithKeyText:self.keyText];
    }
    return _textViewDelegate;
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

- (void)addBorder: (UIView *) view
{
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(0.0f, view.frame.size.height - 1, view.frame.size.width, 1.0f);
    border.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [view.layer addSublayer:border];
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





@end
