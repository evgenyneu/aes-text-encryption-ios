//
//  AESEncryptor.m
//  AESTextEncryption
//
//  Created by Evgenii Neumerzhitckii on 5/11/2013.
//  Copyright (c) 2013 Evgenii Neumerzhitckii. All rights reserved.
//

#import "AESEncryptor.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define ENCRYPTED_PREFIX @"AESCrypto4iOS0"

@interface AESEncryptor()

@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation AESEncryptor

- (JSContext *) jsContext {
  if (!_jsContext) {
    _jsContext = [[JSContext alloc] init];
    NSArray *jsFiles = @[ @"core.js",
                          @"enc-base64.js",
                          @"md5.js",
                          @"evpkdf.js",
                          @"cipher-core.js",
                          @"aes.js",
                          @"encryption_helper.js",
                          @"aes_crypto.js"];

    for (NSString *fileName in jsFiles) {
      [AESEncryptor evaluateJs:_jsContext fromFile: fileName];
    }
  }
  return _jsContext;
}

- (JSValue*) jsObj
{
  return self.jsContext[@"aesCrypto"];
}

- (NSString*) prefix {
  JSValue *functionEncrypt = self.jsObj[@"formatter"][@"prefix"];
  return [functionEncrypt toString];
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
  text = [AESEncryptor strip: text];
  key = [AESEncryptor strip: key];

  if (text.length == 0 || key.length == 0) {
    return @"";
  }

  JSValue *functionEncrypt = self.jsObj[@"encrypt"];

  JSValue *resultEncrypt = [functionEncrypt callWithArguments:@[text, key]];
  NSString *result = [resultEncrypt toString];
  return [AESEncryptor strip: result];
}

- (NSString *) decrypt: (NSString*) text withKey:(NSString*) key
{
  text = [AESEncryptor strip: text];
  key = [AESEncryptor strip: key];

  if (key.length == 0 || ![self isEncrypted:text]) {
    return @"";
  }

  JSValue *functionDecrypt = self.jsObj[@"decrypt"];
  JSValue* resultDecrypt = [functionDecrypt callWithArguments:@[text, key]];
  NSString *result = [resultDecrypt toString];
  return [AESEncryptor strip: result];
}

+ (NSString *) strip: (NSString*) text {
  return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL) isEncrypted: (NSString*) text {
  text = [AESEncryptor strip: text];
  return [text hasPrefix:[self prefix]];
}

@end
