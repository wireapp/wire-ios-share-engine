//
// Wire
// Copyright (C) 2020 Wire Swiss GmbH
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

public class SharingSessionConfiguration: Codable {
    
    /// If set to true, then the app lock feature will use biometric authentication if available,
    /// or fallback on the account password.
    
    public var useBiometricsOrAccountPassword: Bool
    
    /// If set to true, then the app lock feature will require a custom passcode to be created.
    
    public var useCustomCodeInsteadOfAccountPassword: Bool
    
    /// If set to true, the the app lock feature will be mandatory and can not be disabled by the
    /// user.
    
    public var forceAppLock: Bool
    
    /// The amount of seconds in the background before the app will relock.
    
    public var appLockTimeout: UInt
    
    public static func load(from URL: URL) -> SharingSessionConfiguration? {
        guard let data = try? Data(contentsOf: URL) else { return nil }
        
        let decoder = JSONDecoder()
        
        return  try? decoder.decode(SharingSessionConfiguration.self, from: data)
    }
}
