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

#import "dianeXuNavxImport.h"

@implementation NavxImport

@synthesize difGeometry,eamGeometry,lesionGeometry;

- (id)init {
    self = [super init];
    if(self) {
        currentContent = nil;
        difGeometry = [NSMutableArray new];
        eamGeometry = [NSMutableArray new];
        lesionGeometry = [NSMutableArray new];
    }
    return self;
}

#pragma mark XML Parser
- (void) retrieveNavxDataFrom:(NSURL*)sourcePath:(NSError**)errorOutput {
    
    BOOL success = NO;
    BOOL difImport = NO;
    
    NSURL *difPath = [[NSURL alloc] initWithString:@"difs/dif001.xml" relativeToURL:sourcePath];
    NSURL *eamPath = [[NSURL alloc] initWithString:@"ensiteModel/geometry.xml" relativeToURL:sourcePath];
    NSURL *lesionPath = [[NSURL alloc] initWithString:@"ensiteModel/lesions.xml" relativeToURL:sourcePath];
    
    
    NSString *difPathString = [[[difPath absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:difPathString]) {
        NSLog(@"dianeXu: found NavX DIF data for import.");
        difImport = YES;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:difPath cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
        NSURLResponse *response = nil;
    
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:errorOutput];
    
        NSXMLParser *parser;
        parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
    
        success = [parser parse];
    
        [difPath release];
        
        if (!success) {
            *errorOutput = [parser parserError];
        } else {
            [self makePointsFromNavxDIFString:rawNavxData];
        }
    }
NSLog(@"%@",difGeometry);
}

#pragma mark NSXMLParserDelegate
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"Vertices"] && !currentContent) {
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

#pragma mark Data Formatting Methods
- (void)makePointsFromNavxDIFString:(NSString *)inputString {
    
    NSMutableArray *lineCoords = [[inputString componentsSeparatedByString:@"\n"] mutableCopy];
    //trim lines
    [lineCoords removeObjectAtIndex:0];
    [lineCoords removeLastObject];
    
    for (NSString *singleCoord in lineCoords) {
        dianeXuCoord *currentCoord = [dianeXuCoord alloc];
        
        //trim junk from the single lines
        NSString *trimmedSingleCoord = [singleCoord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        //seperate the coords
        NSArray *justCoords = [trimmedSingleCoord componentsSeparatedByString:@"  "];
        
        //set coordinate values and add to eamPoints array.
        [currentCoord setXValue:[NSDecimalNumber  decimalNumberWithString:[justCoords objectAtIndex:0]]];
        [currentCoord setYValue:[NSDecimalNumber decimalNumberWithString:[justCoords objectAtIndex:1]]];
        [currentCoord setZValue:[NSDecimalNumber decimalNumberWithString:[justCoords objectAtIndex:2]]];
        //NSLog(@"%@ %@ %@", [currentCoord xValue],[currentCoord yValue],[currentCoord zValue]);
        
        [difGeometry addObject:currentCoord];
        //NSLog(@"%@", [eamPoints objectAtIndex:[eamPoints count]-1]);
        
        currentCoord = nil;
    }
}

@end
