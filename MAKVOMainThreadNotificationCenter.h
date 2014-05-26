//
//  MAKVONotificationCenterMainThread.h
//  MAKVONotificationCenter
//
//  Created by Martin Nygren on 25/05/2014.
//
//

#import "MAKVONotificationCenter.h"

@interface MAKVOMainThreadNotificationDispatcher : MAKVONotificationDispatcher

// Forwards the observed change to the main thread if necessary.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end

@interface MAKVOMainThreadNotificationCenter : MAKVONotificationCenter

+ (instancetype)defaultCenter;

// Creates a MAKVOMainThreadNotificationDispatcher object.
- (MAKVONotificationDispatcher *)createHelper:(id)observer
                                           object:(id)target
                                         keyPaths:(NSSet *)keyPaths
                                         selector:(SEL)selector
                                         userInfo:(id)userInfo
                                          options:(NSKeyValueObservingOptions)options;

@end
