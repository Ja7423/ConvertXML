//
//  XMLAnalyze.m
//  ConvertXML
//
//  Created by 家瑋 on 2016/8/3.
//  Copyright © 2016年 家瑋. All rights reserved.
//

#import "XMLAnalyze.h"

@implementation XMLAnalyze
{
    NSMutableArray *FinalData;
    NSMutableString *CDATAContent;
    NSMutableString *CharacterContent;
    NSInteger index; //用來表示現在位於xml的第幾層
    NSString *PreviousElement;
    NSError *error;
    SUCCESS Complete;
    FAILURE Fail;

}


- (void)StartAnalysis:(NSURL *)URL Completion:(SUCCESS)Completion OrError:(FAILURE)Error
{

    Complete = Completion;
    Fail = Error;

    NSXMLParser *Parser = [[NSXMLParser alloc]initWithContentsOfURL:URL];
    Parser.delegate = self;
    [Parser parse];
}


#pragma mark -
#pragma mark - NSXMLParser Delegate
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    MYLog(@"**************** Srart ****************");

    FinalData = [NSMutableArray array];
    index = 0;

    CDATAContent = [[NSMutableString alloc]init];
    CharacterContent = [[NSMutableString alloc]init];


}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(nullable NSString *)namespaceURI
 qualifiedName:(nullable NSString *)qName
    attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
{
    MYLog(@"**** didStartElement ****");
    MYLog(@"elementName( %@ )", elementName);
    //    MYLog(@"attributeDict( %@ )", attributeDict);

    PreviousElement = elementName; //用來判斷tag有沒有值


    if ([FinalData count] == index)
    {
        //當沒有進入didEndElement，表示前一個tag沒有結束
        [FinalData addObject:[NSMutableDictionary dictionary]];
    }

    index ++;

    if ([attributeDict count] > 0)
    {
        NSString *arrtibuteName = [NSString stringWithFormat:@"attribute %@", elementName];
        [[FinalData lastObject] setObject:attributeDict forKey:arrtibuteName];
    }

}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    NSString *DataContent = [[NSString alloc]initWithData:CDATABlock encoding:NSUTF8StringEncoding];

    [CDATAContent appendString:DataContent];

    //    MYLog(@"**** foundCDATA ****");
    //    MYLog(@"CDATABlock( %@ )", CDATAContent);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *text = [string stringByTrimmingCharactersInSet: characterSet];
    [CharacterContent appendString:text];

    //    MYLog(@"**** foundCharacters ****");
    //    MYLog(@"Character( %@ )", CharacterContent);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(nullable NSString *)namespaceURI
 qualifiedName:(nullable NSString *)qName
{
    MYLog(@"**** didEndElement ****");
    MYLog(@"elementName( %@ )", elementName);

    NSMutableDictionary *lastobject = [FinalData lastObject];

    if ([CharacterContent length] > 0)
    {
        [lastobject setObject:CharacterContent forKey:elementName];

        CharacterContent = [NSMutableString string];
    }
    else if ([CDATAContent length] > 0)
    {
        id object = [lastobject objectForKey:elementName];
        if (object)
        {
            if ([object isKindOfClass:[NSMutableArray class]])
            {
                [object addObject:CDATAContent];
            }
            else
            {
                NSMutableArray *array = [NSMutableArray array];
                [array addObjectsFromArray:@[object, CDATAContent]];
                [lastobject setObject:array forKey:elementName];
            }
        }
        else
        {
            [lastobject setObject:CDATAContent forKey:elementName];
        }

        CDATAContent = [NSMutableString string];
    }
    else
    {
        if ([PreviousElement isEqualToString:elementName])
        {
            //the tag without value, do nothing...
        }
        else
        {
            id object = [FinalData[index - 1] objectForKey:elementName];

            if (object)
            {
                if ([object isKindOfClass:[NSMutableArray class]])
                {
                    [object addObject:lastobject];
                }
                else
                {
                    NSMutableArray *array = [NSMutableArray array];
                    [array addObjectsFromArray:@[object, lastobject]];
                    [FinalData[index]setObject:array forKey:elementName];
                }
            }
            else
            {
                NSMutableDictionary *dict = FinalData[index - 1];
                [dict setObject:lastobject forKey:elementName];
            }

            [FinalData removeLastObject];
        }
    }

    index -- ;

}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    MYLog(@"**************** End ****************");

    MYLog(@"FinalData");
    MYLog(@"%@", FinalData);

    Complete(FinalData);
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    MYLog(@"**** parseErrorOccurred ****");
    MYLog(@"parseError( %@ )", parseError);

    Fail(parseError);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    MYLog(@"**** validationErrorOccurred ****");
    MYLog(@"validationError( %@ )", validationError);

    Fail(validationError);
}


@end
