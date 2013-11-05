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



@end
