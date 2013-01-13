//
//  dianeXuWindowController.h
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

#import <Cocoa/Cocoa.h>
#import "dianeXuPreferencesKeys.h"
#import "dianeXuNavxImport.h"
#import "dianeXuDataSet.h"
#import "dianeXuITKImageWrapper.h"

@interface dianeXuWindowController : NSWindowController {
    ViewerController* mainViewer;
    ViewerController* scndViewer;
    dianeXuDataSet* workingSet;
    dianeXuStatusWindowController* statusWindow;
    NSUserDefaults *defaultSettings;
    int currentStep;
    NSButton *buttonNext;
    NSButton *buttonPrev;
    NSTabView *tabStep;
    NSPathControl *pathEAM;
    NSTextField *labelEAMSource;
    NSTextField *labelMRINumCoords;
    NSButton *buttonDifRoi;
    NSTextField *labelEAMNumCoords;
    NSTextField *labelLesionNumCoords;
    NSButton *buttonInfo;
    NSButton *pushShowEAMRoi;
}

@property (readonly) ViewerController* mainViewer;
@property (readonly) ViewerController* scndViewer;

@property (assign) IBOutlet NSButton *buttonInfo;
@property (assign) int currentStep;
@property (assign) IBOutlet NSButton *buttonNext;
@property (assign) IBOutlet NSButton *buttonPrev;
@property (assign) IBOutlet NSTabView *tabStep;
@property (assign) IBOutlet NSPathControl *pathEAM;
@property (assign) IBOutlet NSTextField *labelEAMSource;
@property (assign) IBOutlet NSTextField *labelMRINumCoords;
@property (assign) IBOutlet NSButton *buttonDifRoi;
@property (assign) IBOutlet NSTextField *labelEAMNumCoords;
@property (assign) IBOutlet NSTextField *labelLesionNumCoords;

- (IBAction)pushNext:(id)sender;
- (IBAction)pushPrev:(id)sender;
- (IBAction)pushQuit:(id)sender;
- (IBAction)pushInfo:(id)sender;
- (IBAction)pushGetNavxData:(id)sender;
- (IBAction)pushDifRoi:(id)sender;


- (id) initWithViewer:(ViewerController*)mViewer andViewer:(ViewerController*)sViewer;

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

- (void) updateStepGUI:(int)toStep;

@end
