//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
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
import WireMessageStrategy
import WireRequestStrategy
import WireTransport.ZMRequestCancellation


class StrategyFactory {

    unowned let syncContext: NSManagedObjectContext
    let applicationStatus: ApplicationStatus
    private(set) var strategies = [AnyObject]()

    private var tornDown = false

    init(syncContext: NSManagedObjectContext, applicationStatus: ApplicationStatus) {
        self.syncContext = syncContext
        self.applicationStatus = applicationStatus
        self.strategies = createStrategies()
    }

    deinit {
        precondition(tornDown, "Need to call `tearDown` before `deinit`")
    }

    func tearDown() {
        strategies.forEach {
            if $0.responds(to: #selector(ZMObjectSyncStrategy.tearDown)) {
                ($0 as? ZMObjectSyncStrategy)?.tearDown()
            }
        }
        tornDown = true
    }

    private func createStrategies() -> [AnyObject] {
        return [
            // Missing Clients
            createMissingClientsStrategy(),

            // Client Messages
            createClientMessageTranscoder(),

            // Link Previews
            createLinkPreviewAssetUploadRequestStrategy(),
            createLinkPreviewUploadRequestStrategy(),

            // Assets V3
            createAssetClientMessageRequestStrategy(),
            createAssetV3ImageUploadRequestStrategy(),
            createAssetV3FileUploadRequestStrategy()
        ]
    }

    private func createMissingClientsStrategy() -> MissingClientsRequestStrategy {
        return MissingClientsRequestStrategy(withManagedObjectContext: syncContext, applicationStatus: applicationStatus)
    }

    private func createClientMessageTranscoder() -> ClientMessageTranscoder {
        return ClientMessageTranscoder(
            in: syncContext,
            localNotificationDispatcher: PushMessageHandlerDummy(),
            applicationStatus: applicationStatus
        )
    }

    // MARK: – Link Previews

    private func createLinkPreviewAssetUploadRequestStrategy() -> LinkPreviewAssetUploadRequestStrategy {
        
        return LinkPreviewAssetUploadRequestStrategy(
            managedObjectContext: syncContext,
            applicationStatus: applicationStatus,
            linkPreviewPreprocessor: nil,
            previewImagePreprocessor: nil
        )
    }

    private func createLinkPreviewUploadRequestStrategy() -> LinkPreviewUploadRequestStrategy {
        return LinkPreviewUploadRequestStrategy(withManagedObjectContext: syncContext, applicationStatus: applicationStatus)
    }

    // MARK: - Asset V3

    private func createAssetV3FileUploadRequestStrategy() -> AssetV3FileUploadRequestStrategy {
         return AssetV3FileUploadRequestStrategy(withManagedObjectContext: syncContext, applicationStatus: applicationStatus)
    }

    private func createAssetV3ImageUploadRequestStrategy() -> AssetV3ImageUploadRequestStrategy {
        return AssetV3ImageUploadRequestStrategy(withManagedObjectContext: syncContext, applicationStatus: applicationStatus)
    }

    private func createAssetClientMessageRequestStrategy() -> AssetClientMessageRequestStrategy {
        return AssetClientMessageRequestStrategy(withManagedObjectContext: syncContext, applicationStatus: applicationStatus)
    }
}
