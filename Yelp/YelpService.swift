//
//  YelpService.swift
//  Yelp
//
//  Created by Nguyen Quang Ngoc Tan on 2/22/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import AFNetworking
import BDBOAuth1Manager

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
let yelpConsumerKey = "vxKwwcR_NMQ7WaEiQBK_CA"
let yelpConsumerSecret = "33QCvh5bIF5jIHR5klQr7RtBDhQ"
let yelpToken = "uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV"
let yelpTokenSecret = "mqtKIxMIR4iBtBPZCmCLEb-Dz3Y"
let RESULT_LIMIT = 10

enum YelpSortMode: Int {
    case bestMatched = 0, distance, highestRated
}

class YelpService: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    static var _shared: YelpService?
    static func shared() -> YelpService! {
        if _shared == nil {
            _shared = YelpService(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        }
        return _shared
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = URL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    func search(with term: String, completion: @escaping ([Business]?, Error?) -> ()) -> AFHTTPRequestOperation {
        return search(with: term, sort: nil, categories: nil, deals: nil, radius: nil, offset: 0, completion: completion)
    }
    
    func search(with term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, radius: Float?, offset: Int, completion: @escaping ([Business]?, Error?) -> ()) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        // Default the location to San Francisco
        var parameters: [String : AnyObject] = ["term": term as AnyObject, "ll": "37.785771,-122.406165" as AnyObject]
        parameters["limit"] = RESULT_LIMIT as AnyObject?
        parameters["offset"] = offset as AnyObject?
        if sort != nil {
            parameters["sort"] = sort!.rawValue as AnyObject?
        }
        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = (categories!).joined(separator: ",") as AnyObject?
        }
        if radius != nil {
            parameters["radius_filter"] = converMilToMeter(milValue: radius!) as AnyObject?
        }
        if deals != nil {
            parameters["deals_filter"] = deals! as AnyObject?
        }
        print(parameters)
        
        return self.get("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation, response: Any) in
            if let response = response as? NSDictionary {
                let dictionaries = response["businesses"] as? [NSDictionary]
                if dictionaries != nil {
                    completion(Business.businesses(array: dictionaries!), nil)
                }
            }
        }, failure: { (operation: AFHTTPRequestOperation?, error: Error) in
            completion(nil, error)
        })!
    }
    
    func converMilToMeter(milValue: Float) -> Float {
        return milValue * 1609.344
    }

    func getYelpModeAsString(mode: YelpSortMode) -> String {
        switch mode {
        case .bestMatched:
            return "Best matched"
        case .distance:
            return "Distance"
        case .highestRated:
            return "Highest rated"
        default:
            return ""
        }
    }
}
