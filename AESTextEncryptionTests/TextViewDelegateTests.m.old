#import "TestIncludes.h"
#import "TextViewDelegate.h"

SpecBegin(TextViewDelegateTests)

describe(@"get text", ^{
  it(@"returns text", ^{
    NSString *result = [TextViewDelegate text: @"this is text"];
    expect(result).to.equal(@"this is text");
  });

  it(@"returns empty string when placeholder text is supplied", ^{
    NSString *result = [TextViewDelegate text: @"Enter text here. It will be encrypted and copied.\n\nTo decrypt: copy encrypted text from another app and it will be decrypted here. \n\nAES encrypton with 256-bit key is used."];
    expect(result).to.equal(@"");
  });
});

SpecEnd