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
//  Copyright (c) 2012-2013 Dipl.Ing.(FH) Björn Schwarz <beegz@dianeXu.com>. All rights reserved.
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
    NSBox *boxSegAlgorithm;
    NSTextField *labelXmm;
    NSTextField *labelYmm;
    NSTextField *labelZmm;
    NSTextField *labelXpx;
    NSTextField *labelYpx;
    NSTextField *labelZpx;
    NSTextField *labelValue;
    NSTextField *textLowerThreshold;
    NSTextField *textUpperThreshold;
    NSButton *checkPreview;
    NSTextField *labelLowerThresholdProposal;
    NSTextField *labelUpperThresholdProposal;
    NSSegmentedControl *segDifRoi;
    NSSegmentedControl *segSteponeRoi;
    NSSegmentedControl *segDifToggle;
    NSSegmentedControl *segSteponeToggle;
    NSSegmentedControl *segEamToggle;
    NSSegmentedControl *segLesionToggle;
    NSSegmentedControl *segAllToggle;
    NSSegmentedControl *segRegistratedRoi;
    NSButton *buttonShowToggledRois;
    NSButton *buttonRegisterModels;
    NSTextField *labelVisDifCount;
    NSTextField *labelVisAngioCount;
    NSTextField *labelVisEamCount;
    NSTextField *labelVisLesionCount;
    NSButton *buttonInfo;
    NSButton *pushShowEAMRoi;
    NSButton *pushRegisterClouds;
    NSButton *pushShowVisRois;
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
@property (assign) IBOutlet NSTextField *labelEAMNumCoords;
@property (assign) IBOutlet NSTextField *labelLesionNumCoords;
@property (assign) IBOutlet NSBox *boxSegAlgorithm;
@property (assign) IBOutlet NSTextField *labelXmm;
@property (assign) IBOutlet NSTextField *labelYmm;
@property (assign) IBOutlet NSTextField *labelZmm;
@property (assign) IBOutlet NSTextField *labelXpx;
@property (assign) IBOutlet NSTextField *labelYpx;
@property (assign) IBOutlet NSTextField *labelZpx;
@property (assign) IBOutlet NSTextField *labelValue;
@property (assign) IBOutlet NSTextField *textLowerThreshold;
@property (assign) IBOutlet NSTextField *textUpperThreshold;
@property (assign) IBOutlet NSButton *checkPreview;
@property (assign) IBOutlet NSTextField *labelLowerThresholdProposal;
@property (assign) IBOutlet NSTextField *labelUpperThresholdProposal;
@property (assign) IBOutlet NSSegmentedControl *segDifRoi;
@property (assign) IBOutlet NSSegmentedControl *segSteponeRoi;
@property (assign) IBOutlet NSSegmentedControl *segDifToggle;
@property (assign) IBOutlet NSSegmentedControl *segSteponeToggle;
@property (assign) IBOutlet NSSegmentedControl *segEamToggle;
@property (assign) IBOutlet NSSegmentedControl *segLesionToggle;
@property (assign) IBOutlet NSSegmentedControl *segAllToggle;
@property (assign) IBOutlet NSSegmentedControl *segRegistratedRoi;
@property (assign) IBOutlet NSButton *buttonShowToggledRois;
@property (assign) IBOutlet NSButton *buttonRegisterModels;
@property (assign) IBOutlet NSTextField *labelVisDifCount;
@property (assign) IBOutlet NSTextField *labelVisAngioCount;
@property (assign) IBOutlet NSTextField *labelVisEamCount;
@property (assign) IBOutlet NSTextField *labelVisLesionCount;

- (IBAction)pushNext:(id)sender;
- (IBAction)pushPrev:(id)sender;
- (IBAction)pushQuit:(id)sender;
- (IBAction)pushInfo:(id)sender;
- (IBAction)pushGetNavxData:(id)sender;
- (IBAction)pushDifRoi:(id)sender;
- (IBAction)pushSegCompute:(id)sender;
- (IBAction)pushRegisterModels:(id)sender;
- (IBAction)pushRegistratedROI:(id)sender;
- (IBAction)pushSteponeRoi:(id)sender;
- (IBAction)pushShowToggledRois:(id)sender;
- (IBAction)pushToggleAllRois:(id)sender;


/*
* Initializes the plugin window with two viewers
*/
- (id) initWithViewer:(ViewerController*)mViewer andViewer:(ViewerController*)sViewer;

/*
 * TabView method to do stuff when an item in the TabView is selected
 */
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

/*
 * Method to update the gui according to selected step in TabView
 */
- (void) updateStepGUI:(int)toStep;

/*
 * Method to update all general labels to their respective Values
 */
- (void) updateLabelsGUI;

@end
