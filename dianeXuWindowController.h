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
#import "dianeXuStatusWindowController.h"

@interface dianeXuWindowController : NSWindowController {
    int currentStep;
    NSButton *buttonNext;
    NSButton *buttonPrev;
    NSTabView *tabStep;
    dianeXuStatusWindowController* statusWindow;
    NSButton *buttonInfo;
}

@property (assign) IBOutlet NSButton *buttonInfo;
@property (assign) int currentStep;
@property (assign) IBOutlet NSButton *buttonNext;
@property (assign) IBOutlet NSButton *buttonPrev;
@property (assign) IBOutlet NSTabView *tabStep;

- (IBAction)pushNext:(id)sender;
- (IBAction)pushPrev:(id)sender;
- (IBAction)pushQuit:(id)sender;
- (IBAction)pushInfo:(id)sender;

- (void) updateStepGUI: (int)toStep;
- (void) showStatus;
- (void) updateStatus: (NSString*)newStatusText: (int)newPercentage;
- (void) hideStatus;

@end
