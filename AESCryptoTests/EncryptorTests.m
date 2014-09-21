//#import "TestIncludes.h"
//#import "AESEncryptor.h"
//
//SpecBegin(EncryptorTests)
//
//__block AESEncryptor *encryptor;
//
//beforeEach(^{
//  encryptor = [[AESEncryptor alloc] init];
//});
//
//

//describe(@"decrypts", ^{
//  it(@"", ^{
//    NSString *encryptedText = @"AESCryptoV108f46e2fb15f50e9c170442ec5ec70e6fcded6378b13f1a659f0eb65e8eddb2335de8e76be90b2f0a";
//    NSString *decryptedText = [encryptor decrypt:encryptedText withKey:@"test"];
//
//    expect(decryptedText).to.equal(@"My Test Message 日本");
//  });
//});
//
//describe(@"check if text is encrypted", ^{
//  it(@"encrypted", ^{
//    NSString *encrypted = @"AESCryptoV109eb400b7d5f13b7de09c6383c8898d6cfcb4f5f6104de697";
//    expect([encryptor isEncrypted: encrypted]).to.equal(true);
//  });
//
//  it(@"encrypted string with whitespaces and newlines", ^{
//    expect([encryptor isEncrypted: @" \r\n\n AESCryptoV109eb400b7d5f13b7de09c6383c8898d6cfcb4f5f6104de697"]).to.equal(true);
//  });
//
//  it(@"string is not encrypted", ^{
//    expect([encryptor isEncrypted: @"some text"]).to.equal(false);
//  });
//});
//
//
//describe(@"prefix", ^{
//  it(@"returns prefix", ^{
//    expect([encryptor prefix]).to.equal(@"AESCryptoV10");
//  });
//});
//
//
//SpecEnd
