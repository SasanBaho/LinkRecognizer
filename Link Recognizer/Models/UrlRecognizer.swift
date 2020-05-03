//
//  UrlRecognizer.swift
//  textRecognitionApp
//
//  Created by Sasan Baho on 2020-04-08.
//  Copyright © 2020 Sasan Baho. All rights reserved.
//

import Foundation

class UrlRecognizer {
    
    var url = ""
    let k = Constants()
    
    let domainExtensions = ["www.", ".com", ".net", ".ca",".us", ".uk", ".ir", ".tv", ".org", ".ru", ".cc",".ca", ".info", ".live", ".au", ".at", ".br", ".cn",".co", ".dk", ".fr", ".fi", ".de", ".gr", ".hk",".in", ".ie", ".it", ".jp", ".no", ".pt", ".se", ".tr"]
    
    func findUrl(from element : String?) -> String {
        for domain in domainExtensions {
            if (element!.lowercased().range(of: domain) != nil){
               url = element!
                break
            }else {
                url = ""
            }
        }
        return url
    }

}
