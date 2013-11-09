//
//  AESEncryptor.m
//  AESTextEncryption
//
//  Created by Evgenii Neumerzhitckii on 5/11/2013.
//  Copyright (c) 2013 Evgenii Neumerzhitckii. All rights reserved.
//

#import "AESEncryptor.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface AESEncryptor()

@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation AESEncryptor

- (JSContext *) jsContext {
    if (!_jsContext) {
        _jsContext = [[JSContext alloc] init];
         NSArray *jsFiles = @[@"aes.js", @"aes_helper.js"];
        for (NSString *fileName in jsFiles) {
            [AESEncryptor evaluateJs:_jsContext fromFile: fileName];
        }
    }
    return _jsContext;
}

+ (NSString *)loadJsFromFile: (NSString *) name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return jsScript;
}

+ (void)evaluateJs: (JSContext*)context fromFile: (NSString*)fromFile
{
    NSString *script = [AESEncryptor loadJsFromFile:fromFile];
    [context evaluateScript: script];
}

- (NSString *) encrypt: (NSString*) text withKey:(NSString*) key
{
    text = [self strip: text];
    key = [self strip: key];

    JSValue *functionEncrypt = self.jsContext[@"iiAESEncrypt"];
    JSValue *resultEncrypt = [functionEncrypt callWithArguments:@[text, key]];
    NSString *result = [resultEncrypt toString];
    return [self strip: result];
}

- (NSString *) decrypt: (NSString*) text withKey:(NSString*) key
{
    text = [self strip: text];
    key = [self strip: key];

    JSValue *functionDecrypt = self.jsContext[@"iiAESDecrypt"];
    JSValue* resultDecrypt = [functionDecrypt callWithArguments:@[text, key]];
    NSString *result = [resultDecrypt toString];
    return [self strip: result];
}

- (NSString *) strip: (NSString*) text {
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
