//
//  Dissociator.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/11/14.
//
//

#import <Foundation/Foundation.h>
#import "NewsLoader.h"

@interface DissociatedNewsLoader : NewsLoader

- (NSArray *)loadDissociatedNewsForQueries:(NSArray *)queries pageNumber:(int)page;

@end
