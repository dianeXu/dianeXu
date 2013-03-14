//
//  dianeXuFilter.mm
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

#import "dianeXuFilter.h"
#import <OsiriXAPI/PreferencesWindowController.h>

@implementation dianeXuFilter

- (void) initPlugin
{
    //get path for the prefpane icon
    NSString* appPath = [[NSBundle bundleForClass:[dianeXuWindowController class]] bundlePath];
    NSString* iconPath = [[NSString alloc] initWithFormat:@"%@/Contents/Resources/Icon-Small.png",appPath];
    NSImage* appIcon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    //Add PreferencePane to OsiriX Preferences
    [PreferencesWindowController addPluginPaneWithResourceNamed:@"dianeXuPreferences" inBundle:[NSBundle bundleForClass:[self class]] withTitle:@"dianeXu" image:appIcon];
   
}

- (long) filterImage:(NSString*) menuName
{
    NSLog(@"dianeXu: Starting OsiriX plugin...");
    //Plugin Conditions: Ask for medical usage agreement
    int alertResult;
    alertResult = NSRunInformationalAlertPanel(@"WARNING", @"This plugin is not certified for medical usage. Its purpose is limited to research at this point.", @"Quit", @"Agree", nil,nil);
    if (alertResult == NSAlertDefaultReturn) {
        //end prematurely with no errors
        return 0;
    }
    
    dianeXuWindowController* mainWindow;
    
    //If not existent, create the main Window
    NSArray* activeViewers = [ViewerController getDisplayed2DViewers];
    if ([activeViewers count] < 2) {
        NSRunInformationalAlertPanel(@"ERROR", @"This plugin needs two viewers to function properly. Please open a second viewer first.", @"Quit", nil, nil,nil);
        return 0;
    } else if ([activeViewers count]>2) {
        NSRunInformationalAlertPanel(@"WARNING", @"This plugin only uses two viewers. Please check the registred Viewers!", @"OK", nil, nil,nil);
    }
    
    //check for the first two viewers
    mainWindow = [dianeXuFilter getWindowForController:[activeViewers objectAtIndex:0] andController:[activeViewers objectAtIndex:1]];
    
    
    if (!mainWindow) {
        mainWindow = [[dianeXuWindowController alloc] initWithViewer:[activeViewers objectAtIndex:0] andViewer:[activeViewers objectAtIndex:1]];
    }
    
    NSLog(@"dianeXu: Initialized with two viewers, showing main window...");
    //show our plugin window
    [mainWindow showWindow:self];
    
    /*
	ViewerController	*new2DViewer;
	
	// In this plugin, we will simply duplicate the current 2D window!
	
	new2DViewer = [self duplicateCurrent2DViewerWindow];
	
	if( new2DViewer) return 0; // No Errors
	else return -1;*/
    
    return 0;
}

+ (id)getWindowForController:(ViewerController*)mViewer andController:(ViewerController*)sViewer {
    NSArray* windowList = [NSApp windows];
    
    for (id windowItem in windowList) {
        //is the window even ours?
        if ([[[windowItem windowController] windowNibName] isEqualToString:@"dianeXuWindow"]) {
            if ([[windowItem windowController] mainViewer] == mViewer && [[windowItem windowController] scndViewer] == sViewer) {
                NSLog(@"dianeXu: Using existing window...");
                return [windowItem windowController];
            }
        }
    }
    return nil;
}

@end
