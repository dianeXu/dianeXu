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

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        currentStep = 0;
        [self updateStepGUI];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    //If already existent, create the status window
    if (statusWindow == nil) {
        statusWindow = [[dianeXuStatusWindowController alloc] initWithWindowNibName:@"dianeXuStatusWindow"];
    }
}

- (void)updateStepGUI
{
    //TODO: Insert Code
}

- (void)showStatus
{
    [statusWindow showWindow:self];
    [[statusWindow window] setLevel:NSFloatingWindowLevel];
}

- (void)updateStatus: (NSString*)newStatusText
{
    //TODO: insert code
}

- (void)hideStatus
{
    [[statusWindow window] orderOut:self];
}

@end
