//
//  WebSocketManager.swift
//  WebSockectSample
//
//  Created by hanwe on 2021/07/13.
//

import UIKit
import Starscream

protocol WebSocketManagerDelegate: AnyObject {
    func didReceive(event: HWWebSocketEvent, client: WebSocket)
}

enum HWWebSocketEvent {
    case receiveText(String)
//    case binary(Data)
    case pong(Data?)
    case ping(Data?)
    case error(Error?)
    case viabilityChanged(Bool)
    case reconnectSuggested(Bool)
    case cancelled
}

class WebSocketManager {
    
    // MARK: private property
    private var socket: WebSocket
    private var isConnectedFlag = false
    private let server = WebSocketServer()
    private var connectCompleteHandler: (([String: String]) -> Void)?
    private var disconnectCompleteHandler: ((String, UInt16) -> Void)?
    
    // MARK: property
    
    weak var delegate: WebSocketManagerDelegate?
    
    // MARK: lifeCycle
    
    init(serverUrl: String, requestTimeOut: TimeInterval = 5) {
        if URL(string: serverUrl) == nil {
            print("socket serverUrl is invalid")
        }
        let url: URL = URL(string: serverUrl) ?? URL(string: "https://localhost:8080")!
        var request = URLRequest(url: url)
        request.timeoutInterval = requestTimeOut
        self.socket = WebSocket(request: request)
        self.socket.delegate = self
    }
    
    deinit {
        print("deinit WebSockectManager")
    }
    
    // MARK: private function
    
    // MARK: function
    
    func connect(compleHandler: (([String: String]) -> Void)?) {
        self.connectCompleteHandler = compleHandler
        socket.connect()
    }
    
    func disconnect(compleHandler: ((String, UInt16) -> Void)?) {
        self.disconnectCompleteHandler = compleHandler
        socket.disconnect()
    }
    
    func isConnected() -> Bool {
        return self.isConnectedFlag
    }
    
    func wrtie(_ writedString: String) {
        socket.write(string: writedString)
    }
    
}

extension WebSocketManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            self.isConnectedFlag = true
            self.connectCompleteHandler?(headers)
        case .disconnected(let reason, let code):
            self.isConnectedFlag = false
            self.disconnectCompleteHandler?(reason, code)
        case .text(let string):
            self.delegate?.didReceive(event: .receiveText(string), client: client)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(let data):
            self.delegate?.didReceive(event: .ping(data), client: client)
        case .pong(let data):
            self.delegate?.didReceive(event: .pong(data), client: client)
        case .viabilityChanged(let flag):
            self.delegate?.didReceive(event: .viabilityChanged(flag), client: client)
        case .reconnectSuggested(let flag):
            self.delegate?.didReceive(event: .reconnectSuggested(flag), client: client)
        case .cancelled:
            self.isConnectedFlag = false
            self.delegate?.didReceive(event: .cancelled, client: client)
        case .error(let error):
            self.delegate?.didReceive(event: .error(error), client: client)
        }
    }
    
    
}
