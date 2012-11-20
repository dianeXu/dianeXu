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

@interface dianeXuWindowController ()

@end

@implementation dianeXuWindowController
@synthesize currentStep;
@synthesize buttonInfo;
@synthesize labelStep;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        //set properties
        currentStep = 1;
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    //If not existent, create the status window
    if (statusWindow == nil) {
        statusWindow = [[dianeXuStatusWindowController alloc] initWithWindowNibName:@"dianeXuStatusWindow"];
    }
    //update the GUI according to step
    [self updateStepGUI:currentStep];
}

- (IBAction)pushNext:(id)sender {
    currentStep++; //increment the Step
    [self updateStepGUI:currentStep];
}

- (IBAction)pushPrev:(id)sender {
}

- (IBAction)pushQuit:(id)sender {
    [[self window] orderOut:self];
}

- (IBAction)pushInfo:(id)sender {
}

- (void)updateStepGUI: (int)toStep
{
    switch (toStep) {
        case 1:
            [self updateStatus:@"Testing Status"];
            [self showStatus];
            break;
            
        case 2:
            [self hideStatus];
            break;
        default:
            break;
    }
}

- (void)showStatus
{
    [statusWindow showWindow:self];
    [[statusWindow window] setLevel:NSFloatingWindowLevel];
}

- (void)updateStatus: (NSString*)newStatusText
{
    [statusWindow setStatusText:newStatusText];
}

- (void)hideStatus
{
    [[statusWindow window] orderOut:self];
}

@end
