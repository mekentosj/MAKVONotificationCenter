//
//  TestDeliverOnMainThread.m
//  MAKVONotificationCenter
//
//  Created by Martin Nygren on 25/05/2014.
//
//

#import <XCTest/XCTest.h>
#import "MAKVOMainThreadNotificationCenter.h"

@interface TestDeliverOnMainThread : XCTestCase

@property (nonatomic, strong) MAKVOMainThreadNotificationCenter *notificationCenter;
@property (nonatomic, assign) BOOL wasNotified;
@property (nonatomic, strong) NSNumber * observable;

@end

@implementation TestDeliverOnMainThread

- (void)setUp
{
    [super setUp];
    self.notificationCenter = [MAKVOMainThreadNotificationCenter defaultCenter];
    self.wasNotified = NO;
}

- (void)tearDown
{
    self.notificationCenter = nil;
    self.observable = nil;
    [super tearDown];
}

- (void)observeObservableSynchronously:(NSString *)keyPath
						  ofObject:(id)target
							change:(NSDictionary *)change
						  userInfo:(id)userInfo
{
    self.wasNotified = YES;
}

- (void)observeObservableAsynchronously:(NSString *)keyPath
                              ofObject:(id)target
                                change:(NSDictionary *)change
                              userInfo:(id)userInfo
{
    XCTAssertTrue([NSThread isMainThread], @"Notifications must be delivered on the main thread.");
    self.wasNotified = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)testDefaultMethodReturnsCorrectType
{
    XCTAssertTrue([self.notificationCenter isMemberOfClass:[MAKVOMainThreadNotificationCenter class]],
                  @"MAKVONotificationDeliveryHelper's defaultCenter method is expected to return a MAKVONotificationDeliveryHelper object.");
}


- (void)testObservationOnMainThreadIsDeliveredSynchronously
{
    [self.notificationCenter addObserver:self
                                  object:self
                                 keyPath:@"observable"
                                selector:@selector(observeObservableSynchronously:ofObject:change:userInfo:)
                                userInfo:nil
                                 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)];
    self.observable = [NSNumber numberWithInt:4711];
    XCTAssertTrue(self.wasNotified, @"Assigning observable must generate a notification.");
}

- (void)testObservationOnBackgroundThreadIsDeliveredOnMainThread
{
    [self.notificationCenter addObserver:self
                                  object:self
                                 keyPath:@"observable"
                                selector:@selector(observeObservableAsynchronously:ofObject:change:userInfo:)
                                userInfo:nil
                                 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)];
    __block __weak TestDeliverOnMainThread *weak_self = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^(void){
                       weak_self.observable = [NSNumber numberWithInt:42];
                   });
    CFRunLoopRun();
    XCTAssertTrue(self.wasNotified, @"Assigning observable must generate a notification.");
}

@end
