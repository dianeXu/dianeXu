//
//  dianeXuWindowController.mm
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

#import "dianeXuWindowController.h"
#import "dianeXuITK3dRegionGrowing.h"

#import <OsiriXAPI/PreferencesWindowController.h>

@interface dianeXuWindowController ()

@end

@implementation dianeXuWindowController
@synthesize buttonDifRoi;
@synthesize labelEAMNumCoords;
@synthesize labelLesionNumCoords;
@synthesize mainViewer,scndViewer;
@synthesize currentStep;
@synthesize buttonNext,buttonPrev,buttonInfo;
@synthesize tabStep;
@synthesize pathEAM;
@synthesize labelEAMSource,labelMRINumCoords;


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        //set member variables
        statusWindow = [[dianeXuStatusWindowController alloc]initWithWindowNibName:@"dianeXuStatusWindow"];
        workingSet = [[dianeXuDataSet alloc] init];
        currentStep = 0;
        defaultSettings = [NSUserDefaults standardUserDefaults];
        
        //register for important notifications
        NSNotificationCenter *nc;
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(mouseViewerDown:) name:@"mouseDown" object:nil];
    }
    
    return self;
}

/*
 * Initializes the plugin window with two viewers
 */
- (id) initWithViewer: (ViewerController*)mViewer andViewer: (ViewerController*)sViewer {
    
    self = [super initWithWindowNibName:@"dianeXuWindow"];
    
    defaultSettings = [NSUserDefaults standardUserDefaults];
    workingSet = [[dianeXuDataSet alloc] init];
    currentStep = 0;
    
    if (self != nil) {
        mainViewer = mViewer;
        scndViewer = sViewer;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    //update the GUI according to step
    [self updateStepGUI:currentStep];
}

/*
 * TabView method to do stuff when an item in the TabView is selected
 */
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [self updateStepGUI:currentStep];
}

/*
 * Method to update the gui according to selected step in TabView
 */
- (void)updateStepGUI: (int)toStep
{
    switch (toStep) {
        case 0:
            [buttonPrev setEnabled:FALSE];
            [buttonNext setEnabled:TRUE];
            [tabStep selectTabViewItemAtIndex:toStep];
            break;
            
        case 1:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:TRUE];
            [tabStep selectTabViewItemAtIndex:toStep];
            [labelEAMSource setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:dianeXuEAMSourceKey]];
            break;
            
        case 2:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:TRUE];
            [tabStep selectTabViewItemAtIndex:toStep];
            break;
            
        case 3:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:TRUE];
            [tabStep selectTabViewItemAtIndex:toStep];
            break;
            
        case 4:
            [buttonPrev setEnabled:TRUE];
            [buttonNext setEnabled:FALSE];
            [tabStep selectTabViewItemAtIndex:toStep];
            break;
            
        default:
            NSLog(@"Huh? I have no idea what that step is supposed to be. Sorry.");
            break;
    }
}

/*
 * Make the controller react to mousedowns in the viewer
 */
-(void) mouseViewerDown:(NSNotification*)note {
    if ([note object] == mainViewer && currentStep == 0) {
        NSLog(@"Caught click in main viewer while lingering in step 0");
    }
}

- (IBAction)pushNext:(id)sender {
    currentStep++; //increment the Step
    [self updateStepGUI:currentStep];
}

- (IBAction)pushPrev:(id)sender {
    currentStep--; //decrement the Step
    [self updateStepGUI:currentStep];
}

- (IBAction)pushQuit:(id)sender {
    [[self window] orderOut:self];
    //TODO: Clean up everything (especially observers) before deallocating!
    //[self dealloc];
}

- (IBAction)pushInfo:(id)sender {
    dianeXuITK3dRegionGrowing* segmenter = [[dianeXuITK3dRegionGrowing alloc] initWithViewer:mainViewer];
    NSString* roiName = [NSString stringWithFormat:@"RoiName"];
    NSColor* roiColor = [NSColor colorWithCalibratedRed:1.0f green:.1f blue:0.1f alpha:1.0f];
    [segmenter start3dRegionGrowingAt:-1 withSeedPoint:NSMakePoint(130, 124) usingRoiName:roiName andRoiColor:roiColor withAlgorithm:0 lowerThreshold:240 upperThreshold:340 outputResolution:8];
}

- (IBAction)pushGetNavxData:(id)sender {
    [statusWindow setStatusText:@"Importing NavX data..."];
    [statusWindow showStatusText];
    NavxImport *retrieve = [[NavxImport alloc] init];
    NSError *error = nil;

    [retrieve retrieveNavxDataFrom:[pathEAM URL] :&error];
    [workingSet setDifGeometry:[[retrieve difGeometry] copy]];
    [workingSet setEamGeometry:[[retrieve eamGeometry] copy]];
    [workingSet setLesionGeometry:[[retrieve lesionGeometry] copy]];
    
    [retrieve dealloc];
    
    // update interface
    [labelMRINumCoords setStringValue:[NSString stringWithFormat:@"%d",[[workingSet difGeometry] count]]];
    [labelEAMNumCoords setStringValue:[NSString stringWithFormat:@"%d",[[workingSet eamGeometry] count]]];
    [labelLesionNumCoords setStringValue:[NSString stringWithFormat:@"%d",[[workingSet lesionGeometry] count]]];
    // Enable show ROI button now that we have the data
    [buttonDifRoi setEnabled:YES];
    [[statusWindow window] orderOut:nil];
}

- (IBAction)pushDifRoi:(id)sender {
    [workingSet difROItoController:mainViewer];
}
@end
