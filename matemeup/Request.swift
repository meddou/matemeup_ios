//
//  Request.swift
//  matemeup
//
//  Created by Mehdi Meddour on 3/24/18.
//  Copyright © 2018 MateMeUp. All rights reserved.
//

import Foundation

class Request {
    
    func setDefaultUrlParams(_ route: String, _ queryStrings: Dictionary<String, String>) -> String {
        var isFirst: Bool = true
        var ret = route
        
        for (key, value) in queryStrings {
            if (isFirst) {
                ret += "?"
                isFirst = false
            }
            else {
             ret += "&"
            }
            ret += key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "=" + value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        }
        return ret
    }
    
    func getFile(route: String, queryString: Dictionary<String, String>, callback: Callback) -> URLSessionDataTask {
        let request: NSMutableURLRequest = self.initRequest(route, "GET", queryString, [:])
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                    if (error != nil) {
                        callback.fail("")
                    }
                    else {
                        callback.success(data as Any)
                    }
            }
        })
        
        task.resume()
        return task
    }
    
    func initRequest(_ route: String, _ method: String, _ queryString: Dictionary<String, String>, _ body: Dictionary<String, Any>) -> NSMutableURLRequest {

        let request = NSMutableURLRequest(url: NSURL(string: self.setDefaultUrlParams(route, queryString))! as URL)
        
        request.httpMethod = method
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    
    func send(route: String, method: String, queryString: Dictionary<String, String>, body: Dictionary<String, Any>, callback: Callback) -> URLSessionDataTask {
        let request: NSMutableURLRequest = self.initRequest(route, method, queryString, body)
        let session = URLSession.shared


        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
                let jsonObject = (data == nil) ? [:] : try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                    if (jsonObject!["success"] == nil) {
                        callback.fail(jsonObject!["error"] == nil ? "" : jsonObject!["error"] as! String)
                    }
                    else if (jsonObject!["success"] as! Bool == true) {
                        callback.success(jsonObject!["data"]!)
                    }
                    else {
                        callback.fail(jsonObject!["message"] as! String)
                    }
            } catch {
                print(error)
            }
        })
        
        task.resume()
        return task
    }
    
}
