//
//  dianeXuNavxImport.h
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

#import <Foundation/Foundation.h>
#import "dianeXuCoord.h"

@interface NavxImport : NSObject <NSXMLParserDelegate> {
    enum axis {
        noaxis,
        x,
        y,
        z
    };
    enum dataType {
        notype,
        dif,
        eam,
        lesion
    };
    
    NSMutableArray *difGeometry;
    NSMutableArray *eamGeometry;
    NSMutableArray *lesionGeometry;
    NSMutableString *currentContent;
    dianeXuCoord *currentCoord;
    enum axis currentAxis;
    enum dataType currentDataType;
    NSString *rawNavxData;
}

@property (assign) NSMutableArray* difGeometry;
@property (assign) NSMutableArray* eamGeometry;
@property (assign) NSMutableArray* lesionGeometry;

/*
 * Method to import NavX data from given export's base directory
 */
- (void)retrieveNavxDataFrom:(NSURL*)sourcePath:(NSError**)errorOutput;

/*
 *  Method to extract coordinate Data from a parsed dif model String.
 */
- (void)makePointsFromNavxDIFString:(NSString *)inputString;

@end
