//
//  Socket.swift
//  NXT_Programming
//
//  Created by Erick Chong on 11/12/17.
//  Copyright © 2017 LA's BEST. All rights reserved.
//

import Foundation
import SocketIO

class Client {
    // MARK: Shared Instance/Singleton
    static let sharedInstance: Client =  {
        let instance = Client()
        return instance
    }()
    
    // MARK: Local Variable
    var connected: Bool
    var socket: SocketIOClient
    
    // MARK: Init
    init() {
        self.connected = false
        self.socket = SocketIOClient(socketURL: URL(string: "http://robocode-server.herokuapp.com")!)
    }
}
