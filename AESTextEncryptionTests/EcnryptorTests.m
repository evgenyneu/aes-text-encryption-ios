#define EXP_SHORTHAND
#import "Expecta.h"
#import "Specta.h"

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
    it(@"encrypted text always starts with U2FsdGVkX1", ^{
      NSString *encryptedText = [encryptor encrypt:@"My message" withKey:@"my key"];
      expect([encryptedText hasPrefix:@"U2FsdGVkX1"]).to.equal(true);
    });
  });

  describe(@"decrypts", ^{
    // Checks compatibility with openssl.
    // Message was encrypted with following command:
    // echo 'My Test Message 日本' | openssl enc -aes-256-cbc -pass pass:"Secret Passphrase" -e -base64
    it(@"", ^{
      NSString *encryptedText = @"U2FsdGVkX19QoG20T57G9tsv8Vn9VelURHMt+ArpDA878DjrFhtpUgJFn6CyycGi";
      NSString *decryptedText = [encryptor decrypt:encryptedText withKey:@"Secret Passphrase"];

      expect(decryptedText).to.equal(@"My Test Message 日本");
    });
  });

  describe(@"check if text is encrypted", ^{
    it(@"encrypted", ^{
        expect([AESEncryptor isEncrypted: @"U2FsdGVkX1asdhkajshdka"]).to.equal(true);
    });

    it(@"encrypted string with whitespaces and newlines", ^{
      expect([AESEncryptor isEncrypted: @" \r\n\n U2FsdGVkX1asdhkajshdka"]).to.equal(true);
    });

    it(@"string is not encrypted", ^{
      expect([AESEncryptor isEncrypted: @"some text"]).to.equal(false);
    });
  });

  describe(@"get text", ^{
    it(@"return empty string when text contains placeholder text", ^{

    });
  });
SpecEnd
