//
//  SocketIOManager.swift
//  LA's BEST Robotics App
//
//  Created by Erick Chong on 9/20/17.
//  Copyright © 2017 LA's BEST. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    static let socketIO = SocketIOManager()
    private var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "http://robocode-server.herokuapp.com/upload")!)
    //private var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "http:/localhost:3000")!)
    
    override init() {
        super.init()
        socket.on(clientEvent: .connect) { data, ack in
            print("Connected to server")
            print("Your session ID: " + self.socket.sid!)
            //print ("Your UUID: " + self.uuid)
        }
        
        socket.on("chat message") { data, ack in
            let stringData = data[0] as! String
            print("Server message: " +  stringData)
            //print(type(of: stringData))
        }
    }
    
    func send(jsonData: String) {
        socket.emit("chat message", jsonData)
    }
    
    func sendType() {
         socket.emit("client_type", "iPad")
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
}
