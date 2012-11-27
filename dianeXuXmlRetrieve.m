//
//  dianeXuXmlRetrieve.h
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

#import "dianeXuXmlRetrieve.h"

@implementation dianeXuXmlRetrieve

- (id)init {
    self = [super init];
    if(self) {
    //initstuff
    }
    return self;
}

- (NSArray*) retrieveNavxDataFrom:(NSString*)sourcePath:(NSError**)errorOutput {
    NSURL *xmlPath = [NSURL URLWithString:sourcePath];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:xmlPath cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:errorOutput];
    
    if (!data) {
        return nil;
    }
    
    NSRunInformationalAlertPanel(@"DEBUG:", @"Got here", @"OK", nil, nil,nil);
    
    return nil;
}

@end
