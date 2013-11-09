//
//  AESTextEncryptionTests.m
//  AESTextEncryptionTests
//
//  Created by Evgenii Neumerzhitckii on 5/11/2013.
//  Copyright (c) 2013 Evgenii Neumerzhitckii. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AESEncryptor.h"

@interface AESTextEncryptionTests : XCTestCase

@end

@implementation AESTextEncryptionTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEncryptEndDecryptMessage
{
    AESEncryptor *encryptor = [[AESEncryptor alloc] init];
    NSString *encryptedText = [encryptor encrypt:@"My message" withKey:@"my key"];

    XCTAssertFalse([@"My message" isEqualToString:encryptedText]);

    NSString *decryptedText = [encryptor decrypt:encryptedText withKey:@"my key"];

    XCTAssertTrue([@"My message" isEqualToString:decryptedText]);
    
}

- (void)testEncryptionRemovesWhitespacesAndNewlines
{
    AESEncryptor *encryptor = [[AESEncryptor alloc] init];
    NSString *encryptedText = [encryptor encrypt:@"\n my Text \r\n" withKey:@" \n paSS \n"];

    XCTAssertFalse([@"my Text" isEqualToString:encryptedText]);

    NSString *decryptedText = [encryptor decrypt:encryptedText withKey:@"\n\npaSS\n  \r\n "];

    XCTAssertTrue([@"my Text" isEqualToString:decryptedText]);
}

// Decryption test. Checks compatibility with openssl.
// Message was encrypted with openssl command:
// echo 'My Test Message' | openssl enc -aes-256-cbc -pass pass:"Secret Passphrase" -e -base64
- (void)testDecrypt
{
    AESEncryptor *encryptor = [[AESEncryptor alloc] init];
    NSString *encryptedText = @"U2FsdGVkX19QoG20T57G9tsv8Vn9VelURHMt+ArpDA878DjrFhtpUgJFn6CyycGi";
    NSString *decryptedText = [encryptor decrypt:encryptedText withKey:@"Secret Passphrase"];

    XCTAssertTrue([@"My Test Message 日本" isEqualToString:decryptedText]);
}



@end
