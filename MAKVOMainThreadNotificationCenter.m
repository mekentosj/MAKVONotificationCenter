//
//  MAKVONotificationCenterMainThread.m
//  MAKVONotificationCenter
//
//  Created by Martin Nygren on 25/05/2014.
//
//

#import "MAKVOMainThreadNotificationCenter.h"

@implementation MAKVOMainThreadNotificationDispatcher

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( [NSThread isMainThread] )
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        });
    }
}

@end

@implementation MAKVOMainThreadNotificationCenter

+ (instancetype)defaultCenter
{
    static MAKVOMainThreadNotificationCenter *defaultCenter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCenter = [[MAKVOMainThreadNotificationCenter allocWithZone:NULL] init];
    });
    
    return defaultCenter;
}

- (MAKVONotificationDispatcher *)createHelper:(id)observer
                                           object:(id)target
                                         keyPaths:(NSSet *)keyPaths
                                         selector:(SEL)selector
                                         userInfo:(id)userInfo
                                          options:(NSKeyValueObservingOptions)options
{
    return [[MAKVOMainThreadNotificationDispatcher alloc] initWithObserver:observer
                                                                        object:target
                                                                      keyPaths:keyPaths
                                                                      selector:selector
                                                                      userInfo:userInfo
                                                                       options:options];
}

@end
