
#define IsNULL(val) (val==nil || [val isKindOfClass:[NSNull class]])
#define safeAssign(dest, src) \
{	id value = src; \
if(value) \
dest = value; }

#define SAFE(src) \
src!=nil?src:NSNULL

#define IsNULL(val) (val==nil || [val isKindOfClass:[NSNull class]])

#define SAFE_DEF(value, default) ((value==nil)?(default):(value))

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"

@protocol ServerResponseDelegate <NSObject>
- (void) success:(id)response;
- (void) failure:(id)response;
@end

typedef void (^CompletionBlock)(NSDictionary *result, NSError *error);

@interface ConnectionsManager : AFHTTPRequestOperationManager <ServerResponseDelegate>

+ (instancetype)sharedManager;

-(void)fetchMeaningsForAcronym:(NSDictionary *)params withdelegate:(id<ServerResponseDelegate>)delegate;

@end