//
//  dianeXuDataSet.h
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

#import <Foundation/Foundation.h>
#import "dianeXuCoord.h"
#import "dianeXuStatusWindowController.h"
#import <OsiriXAPI/ROI.h>
#import <OsiriXAPI/ViewerController.h>

@interface dianeXuDataSet : NSObject {
    dianeXuStatusWindowController* status;
    NSMutableArray* eamPoints;
    dianeXuCoord* primarySpacing;
    dianeXuCoord* primaryOrigin;
    dianeXuCoord* secondarySpacing;
    dianeXuCoord* secondaryOrigin;
}

- (void)eamROItoController: (ViewerController*)targetController;

- (void)makePointsFromNavxString:(NSString*) inputString;

- (void)updateGeometryInfoFrom:(ViewerController*) primeViewer andFrom: (ViewerController*) secondViewer;

@end
