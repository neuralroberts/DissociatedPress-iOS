//
//  DSPImageStore.m
//  DissociatedPress-iOS
//
//  Created by Joseph Wilkerson on 2/15/15.
//
//

#import "DSPImageStore.h"

@interface DSPImageStore ()

@property (strong, nonatomic) NSMutableDictionary *imageCache;

@end

@implementation DSPImageStore

+ (instancetype)sharedStore
{
    static DSPImageStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return  sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use [DSPImageStore sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearImageStore) name:@"UIApplicationDidReceiveMemoryWarningNotification" object:nil];
    return [super init];
}

- (NSMutableDictionary *)imageCache
{
    if (!_imageCache) {
        _imageCache = [NSMutableDictionary dictionary];
    }
    return _imageCache;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    if (!image) {
        return;
    }
    
    [self.imageCache setObject:image forKey:key];
}

- (UIImage *)imageForKey:(NSString *)key
{
    return self.imageCache[key];
}

- (void)deleteImageForKey:(NSString *)key
{
    if (!key) {
        return;
    }
    
    [self.imageCache removeObjectForKey:key];
}

- (void)clearImageStore
{
    self.imageCache = nil;
}

@end
