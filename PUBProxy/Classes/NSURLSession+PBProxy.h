//
//  NSURLSession+PBProxy.h


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (PBProxy)
+(void)disableHttpProxy;
+(void)enableHttpProxy;
@end

NS_ASSUME_NONNULL_END
