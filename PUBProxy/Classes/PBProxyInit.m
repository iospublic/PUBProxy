//
//  PBProxyInit.m
//  PUBNet

#import "PBProxyInit.h"
#import "PBRequestBlock.h"
#import "PBProxyViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>
#ifdef DEBUG
#define PPLog(...) printf("\n[时间:%s] 函数:%s [位置:%d行]: \n\n====%s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define PPLog(...)
#endif

// Key 可以是0~255的Int
#define PBProxy_XORKEY 0xC9
static void function_PBProxy_XOREncrypt(unsigned char *str, unsigned char key) {
    unsigned char *p = str;
    while (((*p) ^= key) != '\0') {
        p++;
    }
}
#ifdef DEBUG
// 截断构造代码，输出内容替换：unsigned char str[] =
static void xor_truncationString(NSString *string) {
    if (string.length == 0){
        return;
    }
    NSInteger strLength = [string length];
    NSInteger startIndex = 0;

    NSString *empty = @"";
    while (startIndex < strLength) {
        // 获取每四个字符的子串
        NSRange range = NSMakeRange(startIndex, MIN(1, strLength - startIndex));
        NSString *subString = [string substringWithRange:range];
        if (empty.length == 0){
            empty = [NSString stringWithFormat:@"(PBProxy_XORKEY ^ '%@')",subString];
        }else {
            empty = [NSString stringWithFormat:@"%@, (PBProxy_XORKEY ^ '%@')",empty,subString];
        }
        startIndex += 1;
    }
    // 构建代码
    empty = [NSString stringWithFormat:@"unsigned char str[] = {%@, (PBProxy_XORKEY ^ '\\0')};",empty];
    PPLog(@"输出结果====\n\n%@\n",empty);
}
#endif

//获取基础信息（签名证书Hash值）
static id function_oo_baseget(void) {
    // 本地字符，通过异或运算，避免存在于常量区，防止汇编代码直接解析
    unsigned char str[] = {(PBProxy_XORKEY ^ 'd'), (PBProxy_XORKEY ^ '4'), (PBProxy_XORKEY ^ '2'), (PBProxy_XORKEY ^ '4'), (PBProxy_XORKEY ^ '4'), (PBProxy_XORKEY ^ '6'), (PBProxy_XORKEY ^ '9'), (PBProxy_XORKEY ^ 'a'), (PBProxy_XORKEY ^ 'c'), (PBProxy_XORKEY ^ '3'), (PBProxy_XORKEY ^ '6'), (PBProxy_XORKEY ^ 'c'), (PBProxy_XORKEY ^ '4'), (PBProxy_XORKEY ^ 'f'), (PBProxy_XORKEY ^ 'e'), (PBProxy_XORKEY ^ '0'), (PBProxy_XORKEY ^ 'c'), (PBProxy_XORKEY ^ 'a'), (PBProxy_XORKEY ^ 'c'), (PBProxy_XORKEY ^ '2'), (PBProxy_XORKEY ^ '9'), (PBProxy_XORKEY ^ 'c'), (PBProxy_XORKEY ^ 'b'), (PBProxy_XORKEY ^ 'a'), (PBProxy_XORKEY ^ '5'), (PBProxy_XORKEY ^ '4'), (PBProxy_XORKEY ^ '1'), (PBProxy_XORKEY ^ '6'), (PBProxy_XORKEY ^ '9'), (PBProxy_XORKEY ^ '9'), (PBProxy_XORKEY ^ 'e'), (PBProxy_XORKEY ^ '8'), (PBProxy_XORKEY ^ '3'), (PBProxy_XORKEY ^ 'b'), (PBProxy_XORKEY ^ '6'), (PBProxy_XORKEY ^ 'f'), (PBProxy_XORKEY ^ 'a'), (PBProxy_XORKEY ^ '3'), (PBProxy_XORKEY ^ '4'), (PBProxy_XORKEY ^ '2'), (PBProxy_XORKEY ^ '\0')};
    function_PBProxy_XOREncrypt(str, PBProxy_XORKEY);
    // 字符长度
    unsigned int length = sizeof(str);
    unsigned char result[length];
    memcpy(result, str, length);
    return [[NSString alloc] initWithFormat:@"%s", result];
}
// 使用代码签名和验证isCodeSignatureValid
BOOL iscdsgtv(void) {

    // 获取应用程序的路径
    NSString *appPath = [[NSBundle mainBundle] bundlePath];

    // 创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 创建证书路径
    NSString *signaturePath = [appPath stringByAppendingPathComponent:@"_CodeSignature/CodeResources"];
    // 检查证书是否存在
    if ([fileManager fileExistsAtPath:signaturePath]) {
        // 读取证书数据
        NSData *signatureData = [NSData dataWithContentsOfFile:signaturePath];

        // 计算证书的 SHA1 哈希值
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(signatureData.bytes, (CC_LONG)signatureData.length, digest);
        
        // 将 SHA1 哈希值转换为字符串
        NSMutableString *signatureHash = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [signatureHash appendFormat:@"%02x", digest[i]];
        }

        id var_oo_base = function_oo_baseget();
        PPLog(@"本地Hash: %@", var_oo_base);
        // 打印证书的哈希值
        PPLog(@"签名 Hash: %@", signatureHash);
        
        if ([var_oo_base isEqual:signatureHash]){
            PPLog(@" === 签名安全");
            return YES;
        }
    }
    return NO;
}

//参考ZXRequestBlock
@implementation PBProxyInit

+(void)load {
    [self registerModule];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 判断前面是否安全
    if (!iscdsgtv()){
        [self function_oo_unwarn:@"请不要篡改签名"];
    }
    // 禁止网络代理抓包
    if ([PBRequestBlock disableHttpProxy]){
        [self function_oo_unwarn:@"请关闭代理设置"];
    }
    return YES;
}

// 非法警告
- (void)function_oo_unwarn:(NSString *)msg {
    PBProxyViewController *vc = [PBProxyViewController new];
    [vc setValue:msg forKey:@"msg"];
    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
}

@end
