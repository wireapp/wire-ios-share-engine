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
import WireTesting
@testable import WireShareEngine

final class SharingSessionConfigurationTest : ZMTBaseTest {
    
    func testItDecodesConfiguration() throws {
        // Given
        let json = """
        {
            "useBiometricsOrAccountPassword": true,
            "useCustomCodeInsteadOfAccountPassword": true,
            "forceAppLock": true,
            "appLockTimeout": 60
        }
        """
        
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!
        
        // When
        let result = try decoder.decode(SharingSessionConfiguration.self, from: data)
        
        // Then
        XCTAssertEqual(result.useBiometricsOrAccountPassword, true)
        XCTAssertEqual(result.useCustomCodeInsteadOfAccountPassword, true)
        XCTAssertEqual(result.forceAppLock, true)
        XCTAssertEqual(result.appLockTimeout, 60)
    }
}
