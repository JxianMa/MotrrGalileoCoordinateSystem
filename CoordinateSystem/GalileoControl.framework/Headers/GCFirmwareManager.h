//  Created by Chris Harding on 11/27/12.
//  Copyright (c) 2012 MOTRR LLC. All rights reserved.
//

/** The GCFirmwareManager object allows you to update Galileo's firmware. You can access the instance through the `firmwareManager` property of the `Galileo` singleton instance.
 */

#import <Foundation/Foundation.h>

@interface GCFirmwareManager : NSObject

///---------------------------------------------------------------------------------------
/// @name Checking for and applying firmware updates
///---------------------------------------------------------------------------------------


/** Check for a new version of Galileo's firmware.
  @param completionBlock Code block that is to be called when the update check is complete.
 @discussion  This requires an internet connection and for Galileo to be connected.
 */
- (void) checkForUpdate:(void (^)(GCFirmwareUpdateCheckOutcome checkOutcome)) completionBlock;


/** Prompt the user to update their Galileo's firmware to the latest version, if one is available.
 @param completionBlock Code block that is to be called if no update is available, if the user dismisses the update or if the phone is disconnected from the internet.
 @discussion  This requires an internet connection and for Galileo to be connected. If a firmware update is available then the user will be prompted to install it using the Motrr app. If the Motrr app isn't installed, they will instead be prompted to install it from the Apple App Store. Otherwise, the Motrr app will be launched and the user will be taken through the steps required to update Galileo's firmware.
 
 Note that if the app launches either the Apple App Store or the Motrr app then there is no guarantee that completionBlock will be called.
 */
- (void) promptUserToUpdate:(void (^)()) completionBlock;



@end
