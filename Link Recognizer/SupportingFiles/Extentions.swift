//
//  String-isValidUrl.swift
//  Link Recognizer
//
//  Created by Sasan Baho on 2020-04-22.
//  Copyright © 2020 Sasan Baho. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

