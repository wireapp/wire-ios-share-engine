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
import WireDataModel


extension ZMConversation: Conversation {

    public var name: String { return displayName }
    
    public var isTrusted: Bool {
        return securityLevel == .secure
    }
    
    public func appendTextMessage(_ message: String, fetchLinkPreview: Bool) -> Sendable? {
        return appendMessage(withText: message, fetchLinkPreview: fetchLinkPreview) as? Sendable
    }
    
    public func appendImage(_ data: Data, v3: Bool) -> Sendable? {
        return appendMessage(withImageData: data, version3: v3) as? Sendable
    }
    
    public func appendFile(_ metaData: ZMFileMetadata, v3: Bool) -> Sendable? {
        return appendMessage(with: metaData, version3: v3) as? Sendable
    }
    
    public func appendLocation(_ location: LocationData) -> Sendable? {
        return appendMessage(with: location) as? Sendable
    }
    
    /// Adds an observer for when the conversation verification status degrades
    public func add(conversationVerificationDegradedObserver: @escaping (ConversationDegradationInfo)->()) -> TearDownCapable {
        return DegradationObserver(conversation: self, callback: conversationVerificationDegradedObserver)
    }
}

public struct ConversationDegradationInfo {
    
    public let conversation : Conversation
    public let users : Set<ZMUser>
    
    public init(conversation: Conversation, users: Set<ZMUser>) {
        self.users = users
        self.conversation = conversation
    }
}

class DegradationObserver : NSObject, ZMConversationObserver, TearDownCapable {
    
    let callback : (ConversationDegradationInfo)->()
    let conversation : ZMConversation
    private var observer : Any? = nil
    
    init(conversation: ZMConversation, callback: @escaping (ConversationDegradationInfo)->()) {
        self.callback = callback
        self.conversation = conversation
        super.init()
        self.observer = NotificationCenter.default.addObserver(forName: contextWasMergedNotification, object: nil, queue: nil) { [weak self] _ in
                                                DispatchQueue.main.async {
                                                    self?.processSaveNotification()
                                                }
        }
    }
    
    deinit {
        tearDown()
    }
    
    func tearDown() {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }
    
    private func processSaveNotification() {
        if !self.conversation.messagesThatCausedSecurityLevelDegradation.isEmpty {
            let untrustedUsers = Set((self.conversation.activeParticipants.array as! [ZMUser]).filter {
                $0.clients.first { !$0.verified } != nil
            })
            
            self.callback(ConversationDegradationInfo(conversation: self.conversation,
                                                      users: untrustedUsers)
            )
        }
    }
    
    func conversationDidChange(_ note: ConversationChangeInfo) {
        if note.didNotSendMessagesBecauseOfConversationSecurityLevel {
            self.callback(ConversationDegradationInfo(conversation: note.conversation,
                                                      users: Set(note.usersThatCausedConversationToDegrade)))
        }
    }
}
