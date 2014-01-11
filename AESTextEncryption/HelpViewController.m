//
//  HelpViewController.m
//  AESTextEncryption
//
//  Created by Evgenii Neumerzhitckii on 11/01/2014.
//  Copyright (c) 2014 Evgenii Neumerzhitckii. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@property (weak, nonatomic) IBOutlet UITextView *helpText;

@end

@implementation HelpViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.helpText.text = NSLocalizedString(@"HELP_TEXT", @"");
}

@end
