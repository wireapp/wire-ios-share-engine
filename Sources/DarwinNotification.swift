//
// Wire
// Copyright (C) 2019 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation

/// Darwin Notifications are used to communicate between an extension and the
/// containing app. Add a case to the enum for each type of notification
/// you want to post/observe.
///
public enum DarwinNotification: String {
    case shareExtDidSaveNote = "com.wire.wire-ios-share-engine.share-ext-did-save-note"
    
    public var name: CFNotificationName {
        return CFNotificationName(rawValue: self.rawValue as CFString)
    }
    
    public func observe(using block: @escaping CFNotificationCallback) {
        let nc = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterAddObserver(
            nc,                                 // notification center
            nil,                                // observer
            block,                              // callback
            name.rawValue,                      // notification name
            nil,                                // object
            .deliverImmediately                 // suspension behaviour
        )
    }
    
    public func post() {
        let nc = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(
            nc,                                 // notification center
            name,                               // notification name
            nil,                                // object
            nil,                                // user info
            true                                // deliver immediately
        )
    }
}
