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
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//
//  Copyright (c) 2012 Dipl.Ing.(FH) Björn Schwarz <beegz@dianeXu.com>. All rights reserved.
//

#import "dianeXuFilter.h"
#import <OsiriXAPI/PreferencesWindowController.h>

@implementation dianeXuFilter

- (void) initPlugin
{
    //Add PreferencePane to OsiriX Preferences
    [PreferencesWindowController addPluginPaneWithResourceNamed:@"dianeXuPreferences" inBundle:[NSBundle bundleForClass:[self class]] withTitle:@"dianeXu" image:[NSImage imageNamed:@"NSUser"]];
}

- (long) filterImage:(NSString*) menuName
{
    //Plugin Conditions: Ask for medical usage agreement
    int alertResult;
    alertResult = NSRunInformationalAlertPanel(@"WARNING", @"This plugin is not certified for medical usage. It's purpose is limited to research at this point.", @"Quit", @"Agree", nil,nil);
    if (alertResult == NSAlertDefaultReturn)
    {
        return -1;
    }
    
        
	ViewerController	*new2DViewer;
	
	// In this plugin, we will simply duplicate the current 2D window!
	
	new2DViewer = [self duplicateCurrent2DViewerWindow];
	
	if( new2DViewer) return 0; // No Errors
	else return -1;
}

@end
