/**
 * Copyright IBM Corporation 2016, 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

// KituraChatServer is a very simple chat server

import Dispatch
import Foundation

import KituraWebSocket

class ChatService: WebSocketService {
    
    private let connectionsLock = DispatchSemaphore(value: 1)
    
    private var connections = [String: (String, WebSocketConnection)]()
    
    private enum MessageType: Character {
        case clientInChat = "c"
        case connected = "C"
        case disconnected = "D"
        case sentMessage = "M"
        case stoppedTyping = "S"
        case startedTyping = "T"
    }
    
    /// Called when a WebSocket client connects to the server and is connected to a specific
    /// `WebSocketService`.
    ///
    /// - Parameter connection: The `WebSocketConnection` object that represents the client's
    ///                    connection to this `WebSocketService`
    public func connected(connection: WebSocketConnection) {
        // Ignored
    }
    
    /// Called when a WebSocket client disconnects from the server.
    ///
    /// - Parameter connection: The `WebSocketConnection` object that represents the connection that
    ///                    was disconnected from this `WebSocketService`.
    /// - Paramater reason: The `WebSocketCloseReasonCode` that describes why the client disconnected.
    public func disconnected(connection: WebSocketConnection, reason: WebSocketCloseReasonCode) {
        lockConnectionsLock()
        if let disconnectedConnectionData = connections.removeValue(forKey: connection.id) {
            for (_, (_, from)) in connections {
                from.send(message: "\(MessageType.disconnected.rawValue):" + disconnectedConnectionData.0)
            }
        }
        unlockConnectionsLock()
    }
    
    /// Called when a WebSocket client sent a binary message to the server to this `WebSocketService`.
    ///
    /// - Parameter message: A Data struct containing the bytes of the binary message sent by the client.
    /// - Parameter client: The `WebSocketConnection` object that represents the connection over which
    ///                    the client sent the message to this `WebSocketService`
    public func received(message: Data, from: WebSocketConnection) {
        invalidData(from: from, description: "Kitura-Chat-Server only accepts text messages")
    }
    
    /// Called when a WebSocket client sent a text message to the server to this `WebSocketService`.
    ///
    /// - Parameter message: A String containing the text message sent by the client.
    /// - Parameter client: The `WebSocketConnection` object that represents the connection over which
    ///                    the client sent the message to this `WebSocketService`
    public func received(message: String, from: WebSocketConnection) {
        guard message.count > 1 else { return }
        
        guard let messageType = message.first else { return }
        
        let displayName = String(message.dropFirst(2))
        
        if messageType == MessageType.sentMessage.rawValue || messageType == MessageType.startedTyping.rawValue ||
                       messageType == MessageType.stoppedTyping.rawValue {
            lockConnectionsLock()
            let connectionInfo = connections[from.id]
            unlockConnectionsLock()
            
            if  connectionInfo != nil {
                echo(message: message)
            }
        }
        else if messageType == MessageType.connected.rawValue {
            guard displayName.count > 0 else {
                from.close(reason: .invalidDataContents, description: "Connect message must have client's name")
                return
            }
            
            lockConnectionsLock()
            for (_, (clientName, _)) in connections {
                from.send(message: "\(MessageType.clientInChat.rawValue):" + clientName)
            }
            
            connections[from.id] = (displayName, from)
            unlockConnectionsLock()
            
            echo(message: message)
        }
        else {
            invalidData(from: from, description: "First character of the message must be a C, M, S, or T")
        }
    }
    
    private func echo(message: String) {
        lockConnectionsLock()
        for (_, (_, connection)) in connections {
            connection.send(message: message)
        }
        unlockConnectionsLock()
    }
    
    private func invalidData(from: WebSocketConnection, description: String) {
        from.close(reason: .invalidDataContents, description: description)
        lockConnectionsLock()
        let connectionInfo = connections.removeValue(forKey: from.id)
        unlockConnectionsLock()
        
        if let (clientName, _) = connectionInfo {
            echo(message: "\(MessageType.disconnected.rawValue):\(clientName)")
        }
    }
    
    private func lockConnectionsLock() {
        _ = connectionsLock.wait(timeout: DispatchTime.distantFuture)
    }
    
    private func unlockConnectionsLock() {
        connectionsLock.signal()
    }
}
