//
//  PBProxyInit.m
//  PUBNet

#import "PBProxyInit.h"
#import "PBRequestBlock.h"

@implementation PBProxyInit

+(void)load {
    [self registerModule];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [PBRequestBlock handleRequest:^NSURLRequest *(NSURLRequest *request) {
        NSLog(@"拦截到请求-%@",request);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.blockTv.text = [self.blockTv.text stringByAppendingString:[NSString stringWithFormat:@"拦截到请求--%@\n",request]];
//        });
        return request;
    }];
    return YES;
}

@end
