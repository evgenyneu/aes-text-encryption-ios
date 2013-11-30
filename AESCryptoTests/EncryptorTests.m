#import "TestIncludes.h"
#import "AESEncryptor.h"

SpecBegin(EncryptorTests)

__block AESEncryptor *encryptor;

beforeEach(^{
  encryptor = [[AESEncryptor alloc] init];
});


describe(@"encryptes and decryptes", ^{
  it(@"", ^{
    NSString *encryptedText = [encryptor encrypt:@"My message" withKey:@"my key"];
    expect(encryptedText).notTo.equal(@"My message");

    NSString *decryptedText = [encryptor decrypt:encryptedText withKey:@"my key"];
    expect(decryptedText).to.equal(@"My message");
  });

  it(@"works with whitespaces newlines", ^{
    NSString *encryptedText = [encryptor encrypt:@" \nmy Text \r\n" withKey:@"  paSS \n"];
    NSString *decryptedText = [encryptor decrypt:encryptedText withKey:@"\n paSS \r\n"];
    expect(decryptedText).to.equal(@"my Text");
  });
});

describe(@"encrypts", ^{
  it(@"encrypted text always starts with AESCrypto4iOS0", ^{
    NSString *encryptedText = [encryptor encrypt:@"My message" withKey:@"my key"];
    expect([encryptedText hasPrefix:@"AESCrypto4iOS0"]).to.equal(true);
  });
});

describe(@"decrypts", ^{
  it(@"", ^{
    NSString *encryptedText = @"AESCrypto4iOS08f46e2fb15f50e9c170442ec5ec70e6fcded6378b13f1a659f0eb65e8eddb2335de8e76be90b2f0a";
    NSString *decryptedText = [encryptor decrypt:encryptedText withKey:@"test"];

    expect(decryptedText).to.equal(@"My Test Message 日本");
  });
});

describe(@"check if text is encrypted", ^{
  it(@"encrypted", ^{
    NSString *encrypted = @"AESCrypto4iOS09eb400b7d5f13b7de09c6383c8898d6cfcb4f5f6104de697";
    expect([encryptor isEncrypted: encrypted]).to.equal(true);
  });

  it(@"encrypted string with whitespaces and newlines", ^{
    expect([encryptor isEncrypted: @" \r\n\n AESCrypto4iOS09eb400b7d5f13b7de09c6383c8898d6cfcb4f5f6104de697"]).to.equal(true);
  });

  it(@"string is not encrypted", ^{
    expect([encryptor isEncrypted: @"some text"]).to.equal(false);
  });
});


describe(@"prefix", ^{
  it(@"returns prefix", ^{
    expect([encryptor prefix]).to.equal(@"AESCrypto4iOS0");
  });
});


SpecEnd
