//
//  MessageThreadController.swift
//  MessageBoard
//
//  Created by Jocelyn Stuart on 1/23/19.
//  Copyright © 2019 JS. All rights reserved.
//

import Foundation

class MessageThreadController {
    var messageThreads: [MessageThread] = []
    
    //var messageThread: MessageThread?
    
    static var baseURL = URL(string: "https://lambda-message-board.firebaseio.com/")!
    
    func createMessageThread(withTitle title: String, completion: @escaping (Error?) -> Void) {
        let messageThread = MessageThread(title: title)
        
       let threadURL = MessageThreadController.baseURL.appendingPathComponent(messageThread.identifier)
       let threadjson = threadURL.appendingPathExtension("json")
        
        var urlRequest = URLRequest(url: threadjson)
        urlRequest.httpMethod = "PUT"
        
        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(messageThread)
        } catch {
            print(error)
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (_, _, error) in
            if let error = error {
                print(error)
                completion(error)
                return
            }
            self.messageThreads.append(messageThread)
            completion(nil)
        }.resume()
        
    }
    
    func createMessage(messageThread: MessageThread, text: String, sender: String, completion: @escaping (Error?) -> Void) {
        let message = MessageThread.Message(text: text, sender: sender)
        
        MessageThreadController.baseURL.appendPathComponent(messageThread.identifier)
        MessageThreadController.baseURL.appendPathComponent("messages")
        MessageThreadController.baseURL.appendPathExtension("json")
        
        var urlRequest = URLRequest(url: MessageThreadController.baseURL)
        urlRequest.httpMethod = "POST"
        
        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(message)
        } catch {
            print(error)
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: urlRequest) { (_, _, error) in
            if let error = error {
                print(error)
                completion(error)
                return
            }
            messageThread.messages.append(message)
            completion(nil)
            }.resume()
        
    }
    
    func fetchMessageThreads(completion: @escaping (Error?) -> Void) {
        let url = MessageThreadController.baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let decodedDict = try jsonDecoder.decode([String: MessageThread].self, from: data)
                let messageThreads = Array(decodedDict.values)
                self.messageThreads = messageThreads
                completion(nil)
            } catch {
                print("Error decoding received data: \(error)")
                completion(error)
                return
            }
            
            }.resume()
    }
    
    
    
}
