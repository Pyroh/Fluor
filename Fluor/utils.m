/*
 * Schism Tracker - a cross-platform Impulse Tracker clone
 * copyright (c) 2003-2005 Storlek <storlek@rigelseven.com>
 * copyright (c) 2005-2008 Mrs. Brisby <mrs.brisby@nimh.org>
 * copyright (c) 2009 Storlek & Mrs. Brisby
 * copyright (c) 2010-2012 Storlek
 * URL: http://schismtracker.org/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
#include "utils.h"

// Intended to be private
int macosx_ibook_fnswitch(int setting);


/**
 Enable Fn keys as real function keys.

 @return An opaque value given by an opaque function.
 */
unsigned int setFnKeysToOtherMode()
{
    unsigned int res = macosx_ibook_fnswitch(kfntheOtherMode);
    
    CFPreferencesSetValue(CFSTR("com.apple.keyboard.fnState"), kCFBooleanTrue, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPreferencesSynchronize(kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    NSDictionary *dict = @{@"state": @YES};
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.keyboard.fnstatedidchange" object:NULL userInfo:dict deliverImmediately:YES];
    
    return res;
}


/**
 Enable Fn keys as utility keys.

 @return An opaque value given by an opaque function.
 */
unsigned int setFnKeysToAppleMode()
{
    unsigned int res = macosx_ibook_fnswitch(kfnAppleMode);
    
    CFPreferencesSetValue(CFSTR("com.apple.keyboard.fnState"), kCFBooleanFalse, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPreferencesSynchronize(kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    NSDictionary *dict = @{@"state": @NO};
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.keyboard.fnstatedidchange" object:NULL userInfo:dict deliverImmediately:YES];
    
    return res;
}

FnMode getCurrentFnKeyState() {
    Boolean validValue;
    Boolean result = CFPreferencesGetAppBooleanValue(CFSTR("com.apple.keyboard.fnState"), kCFPreferencesAnyApplication, &validValue);
    if (!validValue) return UnknownMode;
    if (result) return OtherMode;
    else return AppleMode;
}

int macosx_ibook_fnswitch(int setting)
{
    kern_return_t kr;
    mach_port_t mp;
    io_service_t so;
    io_connect_t dp;
    io_iterator_t it;
    CFDictionaryRef classToMatch;
    unsigned int res, dummy;
    
    kr = IOMasterPort(bootstrap_port, &mp);
    if (kr != KERN_SUCCESS) return -1;
    
    classToMatch = IOServiceMatching(kIOHIDSystemClass);
    if (classToMatch == NULL) return -1;
    
    kr = IOServiceGetMatchingServices(mp, classToMatch, &it);
    if (kr != KERN_SUCCESS) return -1;
    
    so = IOIteratorNext(it);
    IOObjectRelease(it);
    
    if (!so) return -1;
    
    kr = IOServiceOpen(so, mach_task_self(), kIOHIDParamConnectType, &dp);
    if (kr != KERN_SUCCESS) return -1;
    
    kr = IOHIDGetParameter(dp, CFSTR(kIOHIDFKeyModeKey), sizeof(res), &res, (IOByteCount *) &dummy);
    if (kr != KERN_SUCCESS) {
        IOServiceClose(dp);
        return -1;
    }
    
    if (setting == kfnAppleMode || setting == kfntheOtherMode) {
        dummy = setting;
        kr = IOHIDSetParameter(dp, CFSTR(kIOHIDFKeyModeKey), &dummy, sizeof(dummy));
        if (kr != KERN_SUCCESS) {
            IOServiceClose(dp);
            return -1;
        }
    }
    
    IOServiceClose(dp);
    return res;
}
