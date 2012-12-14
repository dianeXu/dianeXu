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
#import <OsiriXAPI/PreferencesWindowController.h>

@interface dianeXuWindowController ()


@end

@implementation dianeXuWindowController
@synthesize mainViewer,scndViewer;
@synthesize currentStep;
@synthesize buttonNext,buttonPrev,buttonInfo;
@synthesize tabStep;
@synthesize pathEAM;
@synthesize labelEAMSource,labelEAMNumCoords;


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        //set properties
        workingSet = [[dianeXuDataSet alloc] init];
        currentStep = 0;
        defaultSettings = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (id) initWithViewer: (ViewerController*)mViewer andViewer: (ViewerController*)sViewer {
    
    self = [super initWithWindowNibName:@"dianeXuWindow"];
    
    defaultSettings = [NSUserDefaults standardUserDefaults];
    workingSet = [[dianeXuDataSet alloc] init];
    currentStep = 0;
    
    if (self != nil) {
        mainViewer = mViewer;
        scndViewer = sViewer;
        [workingSet updateGeometryInfoFrom:mainViewer andFrom:scndViewer];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    //update the GUI according to step
    [self updateStepGUI:currentStep];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [self updateStepGUI:currentStep];
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
    NSRunInformationalAlertPanel(@"DEBUG:", @"Infopopup", @"OK", nil, nil,nil);
}

- (IBAction)pushGetEAMData:(id)sender {
    XmlRetrieve *retrieve = [[XmlRetrieve alloc] init];
    NSError *error = nil;
    NSString * rawData;
    int vertexCount;
    
    vertexCount = [retrieve retrieveNavxVertixCount:[pathEAM URL] :&error];
    rawData = [[NSString alloc] initWithString:[retrieve retrieveNavxDataFrom:[pathEAM URL] :&error]];
    
    //update interface
    [labelEAMNumCoords setStringValue:[NSString stringWithFormat:@"%d",vertexCount]];
    
    //feed rawData to the workingSet
    [workingSet makePointsFromNavxString:rawData :vertexCount];
}

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
            
            break;
    }
}

@end
