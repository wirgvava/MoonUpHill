//
//  DataNparsing.swift
//  Weather
//
//  Created by konstantine on 11.02.23.
//

import Foundation
import Alamofire

class data {
    
    func data(){
        AF.request("https://httpbin.org/get").response { response in
            debugPrint(response)
        }
    }
        
    
    
}
