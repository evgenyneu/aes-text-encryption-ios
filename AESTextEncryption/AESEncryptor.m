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
        NSString *aesScript = [AESEncryptor loadJsFromFile:@"aes.js"];

        [_jsContext evaluateScript: aesScript];
        [_jsContext evaluateScript: @"function iiEncrypt(text, key) { return CryptoJS.AES.encrypt(text, key).toString(); }"];
        [_jsContext evaluateScript: @"function iiDecrypt(text, key) { return CryptoJS.AES.decrypt(text, key).toString(CryptoJS.enc.Utf8); }"];
    }
    return _jsContext;
}

+ (NSString *)loadJsFromFile: (NSString *) name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return jsScript;
}

- (NSString *) encrypt: (NSString*) text withKey:(NSString*) key
{
    JSValue *functionEncrypt = self.jsContext[@"iiEncrypt"];
    JSValue *resultEncrypt = [functionEncrypt callWithArguments:@[text, key]];
    return [resultEncrypt toString];
}

- (NSString *) decrypt: (NSString*) text withKey:(NSString*) key
{
    JSValue *functionDecrypt = self.jsContext[@"iiDecrypt"];
    JSValue* resultDecrypt = [functionDecrypt callWithArguments:@[text, key]];
    return [resultDecrypt toString];
}

@end
