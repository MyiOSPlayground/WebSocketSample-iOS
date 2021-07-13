//
//  ViewController.swift
//  WebSockectSample
//
//  Created by hanwe on 2021/07/13.
//

import UIKit
import Starscream

class ViewController: UIViewController {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var webSockectManager: WebSocketManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webSockectManager = WebSocketManager(serverUrl: "https://echo.websocket.org")
        self.webSockectManager?.delegate = self
        self.indicator.isHidden = true
    }

    @IBAction func connectAction(_ sender: Any) {
        self.indicator.isHidden = false
        self.indicator.startAnimating()
        if self.webSockectManager?.isConnected() ?? false {
            self.webSockectManager?.disconnect(compleHandler: { reason, code in
                print("disconnected reason: \(reason), code: \(code)")
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
            })
            
        } else {
            self.webSockectManager?.connect(compleHandler: { header in
                print("connected! : \(header)")
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
            })
        }
        
    }
    
    @IBAction func writeAction(_ sender: Any) {
        self.webSockectManager?.wrtie("hello world")
        print("send")
    }
}

extension ViewController: WebSocketManagerDelegate {
    func didReceive(event: HWWebSocketEvent, client: WebSocket) {
//        print("event: \(event), client: \(client)")
        switch event {
        case .receiveText(let text):
            print("received: \(text)")
        case .ping(_):
            print("ping")
        case .pong(_):
            print("pong")
        case .cancelled:
            print("cancelled")
        case .reconnectSuggested(_):
            print("reconnectSuggested")
        case .viabilityChanged(_):
            print("viabilityChanged")
        case .error(let err):
            print("err: \(String(describing: err?.localizedDescription))")
        }
    }
    
    
}

