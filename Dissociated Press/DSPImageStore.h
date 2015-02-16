//
//  DSPImageStore.h
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 2/15/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DSPImageStore : NSObject

+ (instancetype)sharedStore;

- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
- (void)deleteImageForKey:(NSString *)key;
- (void)clearImageStore;


@end
