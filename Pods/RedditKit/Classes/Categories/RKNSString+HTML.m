// Copyright (c) 2008-2014 Sam Soffes, http://soff.es
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RKNSString+HTML.h"

@implementation NSString (HTML)

- (NSString *)stringByUnescapingHTMLEntities
{
    NSMutableString *escapedString = [NSMutableString string];
    NSMutableString *unescapedString = [self mutableCopy];
    NSCharacterSet *characters = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    
    while ([unescapedString length] > 0)
    {
        NSRange r = [unescapedString rangeOfCharacterFromSet:characters];
        if (r.location == NSNotFound)
        {
            [escapedString appendString:unescapedString];
            break;
        }
        
        if (r.location > 0)
        {
            [escapedString appendString:[unescapedString substringToIndex:r.location]];
            [unescapedString deleteCharactersInRange:NSMakeRange(0, r.location)];
        }
        
        if ([unescapedString hasPrefix:@"&lt;"])
        {
            [escapedString appendString:@"<"];
            [unescapedString deleteCharactersInRange:NSMakeRange(0, 4)];
        }
        else if ([unescapedString hasPrefix:@"&gt;"])
        {
            [escapedString appendString:@">"];
            [unescapedString deleteCharactersInRange:NSMakeRange(0, 4)];
        }
        else if ([unescapedString hasPrefix:@"&quot;"])
        {
            [escapedString appendString:@"\""];
            [unescapedString deleteCharactersInRange:NSMakeRange(0, 6)];
        }
        else if ([unescapedString hasPrefix:@"&#39;"])
        {
            [escapedString appendString:@"'"];
            [unescapedString deleteCharactersInRange:NSMakeRange(0, 5)];
        }
        else if ([unescapedString hasPrefix:@"&amp;"])
        {
            [escapedString appendString:@"&"];
            [unescapedString deleteCharactersInRange:NSMakeRange(0, 5)];
        }
        else if ([unescapedString hasPrefix:@"&hellip;"])
        {
            [escapedString appendString:@"…"];
            [unescapedString deleteCharactersInRange:NSMakeRange(0, 8)];
        }
        else
        {
            [escapedString appendString:@"&"];
            [unescapedString deleteCharactersInRange:NSMakeRange(0, 1)];
        }
    }
    
    return [escapedString copy];
}

@end