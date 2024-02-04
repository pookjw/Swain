//
//  HelperManager.mm
//  Swain
//
//  Created by Jinwoo Kim on 2/4/24.
//

#if !SANDBOXED
#import "HelperManager.hpp"
#import <ServiceManagement/ServiceManagement.h>
#import <xpc/xpc.h>

__attribute__((objc_direct_members))
@interface HelperManager () {
    xpc_session_t _helperSession;
    SMAppService *_appService;
    dispatch_queue_t _queue;
}
@property (assign, nonatomic, readonly) xpc_session_t helperSession;
@property (retain, nonatomic, readonly) SMAppService *appService;
@property (retain, nonatomic, readonly) dispatch_queue_t queue;
@end

@implementation HelperManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HelperManager *object;
    
    dispatch_once(&onceToken, ^{
        object = [HelperManager new];
    });

    return object;
}

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"%d", _helperSession == NULL);
    }
    
    return self;
}

- (void)dealloc {
    [_appService release];
    
    if (_queue) {
        dispatch_release(_queue);
    }
    
    [super dealloc];
}

- (void)installHelperWithCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    dispatch_async(self.queue, ^{
        SMAppService *appService = self.appService;
        
        NSError * _Nullable error = nil;
        [appService registerAndReturnError:&error];
        
        completionHandler(error);
    });
}

- (void)uninstallHelperWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    dispatch_async(self.queue, ^{
        SMAppService *appService = self.appService;
        
        NSError * _Nullable error = nil;
        [appService unregisterAndReturnError:&error];
        
        completionHandler(error);
    });
}

- (SMAppService *)appService {
    if (auto appService = _appService) return appService;
    
    SMAppService *appService = [SMAppService daemonServiceWithPlistName:@"com.pookjw.Swain.Helper.plist"];
    
    _appService = [appService retain];
    return appService;
}

- (dispatch_queue_t)queue {
    if (auto queue = _queue) return queue;
        
    dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, QOS_MIN_RELATIVE_PRIORITY);
    dispatch_queue_t queue = dispatch_queue_create("HelperManager", attr);
    _queue = queue;
    
    return queue;
}

- (xpc_session_t)helperSession {
    if (auto helperSession = _helperSession) return helperSession;
    
    xpc_rich_error_t richError = NULL;
    
    xpc_session_t helperSession = xpc_session_create_mach_service("com.pookjw.Swain.Helper",
                                                                  NULL,
                                                                  XPC_SESSION_CREATE_MACH_PRIVILEGED,
                                                                  &richError);
    
    if (richError) {
        const char *description = xpc_rich_error_copy_description(richError);
        NSString *string = [NSString stringWithCString:description encoding:NSUTF8StringEncoding];
        delete description;
        
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:string userInfo:nil];
    }
    
    _helperSession = helperSession;
    return helperSession;
}

- (void)installPackageWithURL:(NSURL *)packageURL completionHandler:(void (^)(NSError * _Nullable))completionHandler {
    dispatch_async(self.queue, ^{
        xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
        
        xpc_session_send_message_with_reply_async(self.helperSession,
                                                  message,
                                                  ^(xpc_object_t  _Nullable reply, xpc_rich_error_t  _Nullable error) {
            NSLog(@"Hello!");
        });
        
        xpc_release(message);
    });
}

@end
#endif
