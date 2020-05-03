//
//  Spinner.swift
//  Crowser
//
//  Created by Sasan Baho on 2020-04-15.
//  Copyright © 2020 Sasan Baho. All rights reserved.
//

import Foundation
import UIKit

class Spinner {
    
    var vSpinner : UIView?
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor(named: "my-gray")
        let ai = UIActivityIndicatorView.init(style: .medium)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
         self.vSpinner?.removeFromSuperview()
         self.vSpinner = nil
        }
    }
}
