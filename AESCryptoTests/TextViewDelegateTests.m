#import <XCTest/XCTest.h>
#import "TextViewDelegate.h"

@interface TextViewDelegateTests : XCTestCase

@end

@implementation TextViewDelegateTests

// Get text
// ---------

- (void)testReturnText
{
  NSString *result = [TextViewDelegate text: @"this is text"];
  XCTAssertEqualObjects(result, @"this is text");
}

- (void)testReturnEmptyStringWhenPlaceholderTextIsSupplied
{
  NSString *result = [TextViewDelegate text: @"Message"];
  XCTAssertEqualObjects(result, @"");
}

@end
