//
//  dieneXuNavxImport.m
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
//  Copyright (c) 2012-2013 Dipl.Ing.(FH) Björn Schwarz <beegz@dianeXu.com>. All rights reserved.
//

#import "dianeXuNavxImport.h"

@implementation NavxImport

@synthesize difGeometry,eamGeometry,lesionGeometry;

- (id)init {
    self = [super init];
    if(self) {
        isName = false;
        sName = [NSString new];
        currentContent = nil;
        currentCoord = nil;
        currentAxis = noaxis;
        currentDataType = notype;
        difGeometry = [NSMutableArray new];
        eamGeometry = [NSMutableArray new];
        lesionGeometry = [NSMutableArray new];
    }
    return self;
}

#pragma mark XML Parser
- (void) retrieveNavxDataFrom:(NSURL*)sourcePath withError:(NSError**)errorOutput {
    
    BOOL success = NO;

    NSURL *difPath = [[NSURL alloc] initWithString:@"difs/dif001.xml" relativeToURL:sourcePath];
    NSURL *eamPath = [[NSURL alloc] initWithString:@"ensiteModel/geometry.xml" relativeToURL:sourcePath];
    NSURL *lesionPath = [[NSURL alloc] initWithString:@"ensiteModel/lesions.xml" relativeToURL:sourcePath];

    
#pragma mark DIF Import Section
    // Strign to check for availabilty of dif data
    NSString *difPathString = [[[difPath absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
    
    // import only if dif data is present
    if ([[NSFileManager defaultManager] fileExistsAtPath:difPathString]) {
        NSLog(@"dianeXu: Found NavX DIF data for import.");
        
        NSURLRequest *difRequest = [NSURLRequest requestWithURL:difPath cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
        NSURLResponse *difResponse = nil;
    
        NSData *difData = [NSURLConnection sendSynchronousRequest:difRequest returningResponse:&difResponse error:errorOutput];
    
        NSXMLParser *difParser;
        difParser = [[NSXMLParser alloc] initWithData:difData];
        [difParser setDelegate:self];
    
        success = [difParser parse];
    
        [difPath release];
        
        if (!success) {
            NSLog(@"dianeXu: Error importing DIF data.");
            *errorOutput = [difParser parserError];
        } else {
            [self makePointsFromNavxDIFString:rawNavxData];
        }
    }
#pragma mark EAM import section
    NSURLRequest *eamRequest = [NSURLRequest requestWithURL:eamPath cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    NSURLResponse *eamResponse = nil;
    
    NSData *eamData = [NSURLConnection sendSynchronousRequest:eamRequest returningResponse:&eamResponse error:errorOutput];
    
    NSXMLParser *eamParser;
    eamParser = [[NSXMLParser alloc] initWithData:eamData];
    [eamParser setDelegate:self];
    
    success = [eamParser parse];
    
    [eamPath release];
    
    if (!success) {
        NSLog(@"dianeXu: Error importing EAM data.");
        *errorOutput = [eamParser parserError];
    }

#pragma mark lesion import section
    NSURLRequest *lesionRequest = [NSURLRequest requestWithURL:lesionPath cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    NSURLResponse *lesionResponse = nil;
    
    NSData *lesionData = [NSURLConnection sendSynchronousRequest:lesionRequest returningResponse:&lesionResponse error:errorOutput];
    
    NSXMLParser *lesionParser;
    lesionParser = [[NSXMLParser alloc] initWithData:lesionData];
    [lesionParser setDelegate:self];
    
    success = [lesionParser parse];
    
    [lesionPath release];
    
    if (!success) {
        NSLog(@"dianeXu: Error importing lesion data.");
        *errorOutput = [lesionParser parserError];
    }
    
    // verbose result logging
    //NSLog(@"%@",difGeometry);
    //NSLog(@"%@",eamGeometry);
    //NSLog(@"%@",lesionGeometry);


}


#pragma mark NSXMLParserDelegate
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"Vertices"] && !currentContent) {
        currentContent = [NSMutableString string];
        currentDataType = dif;
    } else if (([elementName isEqualToString:@"Label"] || [elementName isEqualToString:@"Pt"]) && !currentCoord) {
        currentCoord = [dianeXuCoord new];
    } else if (([elementName isEqualToString:@"x"] || [elementName isEqualToString:@"Coord_x"]) && currentCoord) {
        currentAxis = x;
        currentDataType = eam;
        if ([elementName isEqualToString:@"Coord_x"]) {
            currentDataType = lesion;
        }
    } else if (([elementName isEqualToString:@"y"] || [elementName isEqualToString:@"Coord_y"]) && currentCoord) {
        currentAxis = y;
        currentDataType = eam;
        if ([elementName isEqualToString:@"Coord_y"]) {
            currentDataType = lesion;
        }
    } else if (([elementName isEqualToString:@"z"] || [elementName isEqualToString:@"Coord_z"])&& currentCoord) {
        currentAxis = z;
        currentDataType = eam;
        if ([elementName isEqualToString:@"Coord_z"]) {
            currentDataType = lesion;
        }
        
    } else if ([elementName isEqualToString:@"Name"]) {
        isName = true;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // check if we're in a name tag
    if (isName == true) {
        sName = string;
    }
    
    if (currentDataType == dif && currentContent) {
        [currentContent appendString: string];
    } else if (((currentDataType == eam && [sName isEqualToString:@"LA"]) || currentDataType == lesion) && currentCoord) {
        if (currentAxis == x) {
            [currentCoord setXValue:[NSDecimalNumber decimalNumberWithString:string]];
        } else if (currentAxis == y) {
            [currentCoord setYValue:[NSDecimalNumber decimalNumberWithString:string]];
        } else if (currentAxis == z) {
            [currentCoord setZValue:[NSDecimalNumber decimalNumberWithString:string]];
        }
    }
    
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"Vertices"] && currentContent) {
        rawNavxData = currentContent;
        currentContent = nil;
    
    } else if ([elementName isEqualToString:@"Label"] && currentCoord) {
        [lesionGeometry addObject:currentCoord];
        currentCoord = nil;
        currentDataType = notype;
        
    } else if ([elementName isEqualToString:@"Pt"] && currentCoord) {
        [eamGeometry addObject:currentCoord];
        currentCoord = nil;
        currentDataType = notype;
    }
    currentAxis = noaxis;
}

#pragma mark Data Formatting Methods
- (void)makePointsFromNavxDIFString:(NSString *)inputString {
    
    NSMutableArray *lineCoords = [[inputString componentsSeparatedByString:@"\n"] mutableCopy];
    //trim lines
    [lineCoords removeObjectAtIndex:0];
    [lineCoords removeLastObject];
    
    for (NSString *singleCoord in lineCoords) {
        dianeXuCoord *localCurrentCoord = [dianeXuCoord alloc];
        
        //trim junk from the single lines
        NSString *trimmedSingleCoord = [singleCoord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        //seperate the coords
        NSArray *justCoords = [trimmedSingleCoord componentsSeparatedByString:@"  "];
        
        //set coordinate values and add to difGeometry array
        [localCurrentCoord setXValue:[NSDecimalNumber  decimalNumberWithString:[justCoords objectAtIndex:0]]];
        [localCurrentCoord setYValue:[NSDecimalNumber decimalNumberWithString:[justCoords objectAtIndex:1]]];
        [localCurrentCoord setZValue:[NSDecimalNumber decimalNumberWithString:[justCoords objectAtIndex:2]]];
        //correct z-axis orientation invert
        [localCurrentCoord setZValue:[[NSDecimalNumber decimalNumberWithString:@"0"] decimalNumberBySubtracting:[localCurrentCoord zValue]]];
        //NSLog(@"%@ %@ %@", [localCurrentCoord xValue],[localCurrentCoord yValue],[localCurrentCoord zValue]);
        
        [difGeometry addObject:localCurrentCoord];
        //NSLog(@"%@", [difGeometry objectAtIndex:[difGeometry count]-1]);
        
        localCurrentCoord = nil;
    }
}

@end
