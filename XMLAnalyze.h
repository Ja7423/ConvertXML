//
//  XMLAnalyze.h
//  ConvertXML
//
//  Created by 家瑋 on 2016/8/3.
//  Copyright © 2016年 家瑋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLAnalyze : NSObject <NSXMLParserDelegate>

typedef void (^SUCCESS)(NSMutableArray * Data);
typedef void (^FAILURE)(NSError * ErrorMsg);


- (void)StartAnalysis:(NSURL *)URL Completion:(SUCCESS)Completion OrError:(FAILURE)Error;


@end
