//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 15/7/14.
//
//

#import "WXApi.h"
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "XMLDictionary.h"


@implementation WXApiRequestHandler

#pragma mark - Public Methods
+ (NSString*)MD5:(NSString*)strI
{
    // Create pointer to the string as UTF8
    const char *ptr = [strI UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+(NSString*) genPackageSign:(NSMutableDictionary*) dict WXApiKey:(NSString *) WXApiKey {
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", WXApiKey];
    return [self MD5:contentString];
}

+ (NSString*) toXml:(NSMutableDictionary*)params {
    
    NSArray *keys = [params allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSString* sb = @"<xml>";
    for (NSString *categoryId in sortedArray) {
        if (![categoryId isEqualToString:@"sign"]) {
            NSString*v = [params objectForKey:categoryId];
            sb = [NSString stringWithFormat:@"%@<%@>%@</%@>", sb, categoryId, v, categoryId];
        }
    }
    sb = [NSString stringWithFormat:@"%@<sign>%@</sign></xml>", sb, [params objectForKey:@"sign"]];
    
    //    Log.e("orion", sb.toString());
    return sb;
}

+ (NSString *)jumpToBizPay: (NSString*) WXAppId WXApiKey:(NSString *) WXApiKey WXPartnerKey:(NSString *) WXPartnerKey {
    NSString *nonce_str = [self MD5:[NSString stringWithFormat:@"%d",arc4random()]];
    NSString *out_trade_no = [self MD5:[NSString stringWithFormat:@"%d",arc4random()]];
    NSString *URLString = [NSString stringWithFormat:@"https://api.mch.weixin.qq.com/pay/unifiedorder"];
    
    NSMutableDictionary *packageParams = [[NSMutableDictionary alloc] init];
    [packageParams setObject: WXAppId  forKey:@"appid"];       //开放平台appid
    [packageParams setObject: @"MemberShip"    forKey:@"body"];        //订单描述，展示给用户
    [packageParams setObject: WXPartnerKey  forKey:@"mch_id"];      //商户号
    [packageParams setObject: nonce_str     forKey:@"nonce_str"];   //随机串
    [packageParams setObject: @"http://weixin.qq.com"  forKey:@"notify_url"];  //支付结果异步通知
    [packageParams setObject: out_trade_no      forKey:@"out_trade_no"];//商户订单号
    [packageParams setObject: @"127.0.0.1"      forKey:@"spbill_create_ip"];//发器支付的机器ip
    [packageParams setObject: @"2000"   forKey:@"total_fee"];       //订单金额，单位为分
    [packageParams setObject: @"APP"    forKey:@"trade_type"];  //支付类型，固定为APP
    
    [packageParams setObject:[self genPackageSign:packageParams WXApiKey:WXApiKey] forKey:@"sign"];
    
    NSString*ent = [self toXml:packageParams];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *httData = [ent dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:httData];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"dataTaskWithRequest error: %@", error);
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            if (statusCode != 200) {
                NSLog(@"Expected responseCode == 200; received %ld", (long)statusCode);
            } else {
                
                NSString *fetchedXML = [NSString stringWithCString:[data bytes] encoding:NSISOLatin1StringEncoding];
                
                
                
                NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLString:fetchedXML];
                NSLog(@"%@", xmlDoc);
                
                Boolean isSuccess = NO;
                if ([[xmlDoc objectForKey:@"return_code"] isEqualToString:@"SUCCESS"]) {
                    if ([[xmlDoc objectForKey:@"result_code"] isEqualToString:@"SUCCESS"]) {
                        isSuccess = YES;
                        
                        NSString    *package, *time_stamp, *nonce_str, *prePayid;
                        prePayid = [xmlDoc objectForKey:@"prepay_id"];
                        //设置支付参数
                        time_t now;
                        time(&now);
                        time_stamp  = [NSString stringWithFormat:@"%ld", now];
                        nonce_str = [self MD5:time_stamp];
                        package         = @"Sign=WXPay";
                        //第二次签名参数列表
                        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
                        [signParams setObject: WXAppId  forKey:@"appid"];
                        [signParams setObject: WXPartnerKey  forKey:@"partnerid"];
                        [signParams setObject: nonce_str    forKey:@"noncestr"];
                        [signParams setObject: package      forKey:@"package"];
                        [signParams setObject: time_stamp   forKey:@"timestamp"];
                        [signParams setObject: prePayid     forKey:@"prepayid"];
                        
                        NSString *sign = [self genPackageSign:signParams WXApiKey: WXApiKey];
                        
                        PayReq* req             = [[PayReq alloc] init];
                        req.partnerId           = WXPartnerKey;
                        req.prepayId            = prePayid;
                        req.nonceStr            = nonce_str;
                        req.timeStamp           = time_stamp.intValue;
                        req.package             = package;
                        req.sign                = sign;
                        [WXApi sendReq:req];
                    }
                }
            }
        }
        
    }];
    [task resume];
    
    return @"";
    
}

@end
