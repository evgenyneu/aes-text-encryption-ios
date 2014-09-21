//
//  AESCryptoTests.m
//  AESCryptoTests
//
//  Created by Evgenii Neumerzhitckii on 24/11/2013.
//  Copyright (c) 2013 Evgenii Neumerzhitckii. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AESEncryptor.h"

@interface AESCryptoTests : XCTestCase

@end

@implementation AESCryptoTests

AESEncryptor *encryptor;

- (void)setUp
{
    [super setUp];
    encryptor = [[AESEncryptor alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Encrypts and decrypts
// -------------------

- (void)testEncryptsAndDecrypts
{
  NSString *encryptedText = [encryptor encrypt:@"My message" withKey:@"my key"];
  XCTAssertNotEqualObjects(encryptedText, @"My message");

  NSString *decryptedText = [encryptor decrypt:encryptedText withKey:@"my key"];

  XCTAssertEqualObjects(decryptedText, @"My message");
}

- (void)testEncryptsAndDecrypts_WithWhitespacesAndNewlines
{
  NSString *encryptedText = [encryptor encrypt:@" \nmy Text \r\n" withKey:@"  paSS \n"];
  NSString *decryptedText = [encryptor decrypt:encryptedText withKey:@"\n paSS \r\n"];
  XCTAssertEqualObjects(decryptedText, @"my Text");
}

// Encrypts
// ---------

- (void)testEncrypts_EncryptedTextAlwaysStartsWithAESCryptoV10
{
  NSString *encryptedText = [encryptor encrypt:@"My message" withKey:@"my key"];
  XCTAssert([encryptedText hasPrefix:@"AESCryptoV10"]);
}

// Decrypts
// ---------

- (void)testDecrypts
{
  NSString *encryptedText = @"AESCryptoV108f46e2fb15f50e9c170442ec5ec70e6fcded6378b13f1a659f0eb65e8eddb2335de8e76be90b2f0a";
  NSString *decryptedText = [encryptor decrypt:encryptedText withKey:@"test"];

  XCTAssertEqualObjects(decryptedText, @"My Test Message 日本");
}

@end
