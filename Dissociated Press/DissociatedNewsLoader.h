//
//  Dissociator.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 11/11/14.
//  Copyright (c) 2014 Joseph Wilkerson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsLoader.h"

@interface DissociatedNewsLoader : NewsLoader

- (NSArray *)loadDissociatedNewsForQueries:(NSArray *)queries pageNumber:(int)page;

@end
