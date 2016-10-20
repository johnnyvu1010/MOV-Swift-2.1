
//
//  MVSyncManager.swift
//  MOVV
//
//  Created by Poslovanje Kvadrat on 05.07.2015..
//  Copyright (c) 2015. Martino Mamic. All rights reserved.
//

import UIKit
import CryptoSwift
import AFNetworking

let kAppId: String = "1";
let kAppSecret: String = "test";


class MVSyncManager: NSObject {
    
    typealias SuccessBlock = (AnyObject!) -> Void
    typealias FailureBlock = (String!) -> Void

    class func getDataFromServerUsingPOST(parameters : NSDictionary, request : String, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let serverUrl : String! = baseURL!
        let manager = AFHTTPRequestOperationManager()
        
        print("\(serverUrl)\(request)")
        print(parameters)
        
        let hash: String = (kAppId + kAppSecret.sha256()).sha256()
        print (hash)
        let encodedParams: NSMutableDictionary = NSMutableDictionary(dictionary: parameters)
        encodedParams["api_key"] = hash
        
        manager.responseSerializer.acceptableContentTypes = NSSet(objects:"application/json", "text/json", "text/javascript", "text/html") as Set<NSObject>
        manager.POST( "\(serverUrl)\(request)/",
            parameters: encodedParams,
            success: { (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                print(responseObject)
                if (responseObject["status"] as! String == "0") {
                    failureBlock(String(responseObject["message"]!!))
                } else {
                    successBlock(responseObject)
                }
            },
            failure: { (operation: AFHTTPRequestOperation?,error: NSError!) in
                print(error)
                failureBlock(error.localizedDescription)
        })
    }
    
    class func getDataFromServerUsingGET(parameters : NSDictionary, request : String, successBlock: SuccessBlock!, failureBlock: FailureBlock!)
    {
        let serverUrl : String! = baseURL!
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects:"application/json", "text/json", "text/javascript", "text/html") as Set<NSObject>
        
        print("\(serverUrl)\(request)")
        print(parameters)
        
        let hash: String = (kAppId + kAppSecret.sha256()).sha256()
        print (hash)
        let encodedParams: NSMutableDictionary = NSMutableDictionary(dictionary: parameters)
        encodedParams["api_key"] = hash
        
        manager.GET( "\(serverUrl)\(request)/",
            parameters: encodedParams,
            success: { (operation: AFHTTPRequestOperation?,responseObject: AnyObject!) in
                print(responseObject)
                if (responseObject["status"] as! String == "0") {
                    failureBlock(String(responseObject["message"]!!))
                } else {
                    successBlock(responseObject)
                }
            },
            failure: { (operation: AFHTTPRequestOperation?,error: NSError!) in
                print(error)
                failureBlock(error!.localizedDescription)
        })
    }
}
