//
//  TextViewDelegate.h
//  AESTextEncryption
//
//  Created by Evgenii Neumerzhitckii on 10/11/2013.
//  Copyright (c) 2013 Evgenii Neumerzhitckii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextViewDelegate : NSObject <UITextViewDelegate>

+ (UIColor*) placeholderColor;
- (id) initWithKeyText: (UITextField*) keyText;
- (void)setTextPlaceholder: (UITextView *)textView;

@end
