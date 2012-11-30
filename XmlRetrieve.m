//
//  XmlRetrieve.h
//  This file is part of dianeXu <http://www.dianeXu.com>.
//
//  dianeXu is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  dianeXu is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with dianeXu.  If not, see <http://www.gnu.org/licenses/>.
//
//  Copyright (c) 2012 Dipl.Ing.(FH) Björn Schwarz <beegz@dianeXu.com>. All rights reserved.
//

#import "XmlRetrieve.h"

@implementation XmlRetrieve

- (id)init {
    self = [super init];
    if(self) {
        countNavx = 0;
        currentContent = nil;
    }
    return self;
}

- (NSString*) retrieveNavxDataFrom:(NSURL*)sourcePath:(NSError**)errorOutput {
    
    BOOL success;
    NSURL *xmlPath = [[NSURL alloc] initWithString:@"difs/dif001.xml" relativeToURL:sourcePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:xmlPath cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:errorOutput];
    
    NSXMLParser *parser;
    parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    
    success = [parser parse];
    
    [xmlPath release];
    
    if (!success) {
        *errorOutput = [parser parserError];
        return nil;
    }
    
    return rawNavxData;
}

- (int) retrieveNavxVertixCount:(NSURL*)sourcePath:(NSError**)errorOutput {
    
    BOOL success;
    NSURL *xmlPath = [[NSURL alloc] initWithString:@"difs/dif001.xml" relativeToURL:sourcePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:xmlPath cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:errorOutput];
    
    NSXMLParser *parser;
    parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    
    success = [parser parse];
    
    [xmlPath release];
    if (!success) {
        *errorOutput = [parser parserError];
        return 0;
    }
    
    return countNavx;
}

#pragma mark NSXMLParserDelegate
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"Vertices"] && !currentContent) {
        countNavx = [[attributeDict objectForKey:@"number"] intValue];
        currentContent = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (currentContent) {
        [currentContent appendString: string];
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"Vertices"] && currentContent) {
        rawNavxData = currentContent;
        currentContent = nil;
    }
}


@end
