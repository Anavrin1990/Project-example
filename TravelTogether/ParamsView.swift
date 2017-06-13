//
//  ParamsView.swift
//  TravelTogether
//
//  Created by Dmitry on 03.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

protocol ParamsViewDelegate {
    func onParamsViewClick(index: Int)
}

class ParamsView: UIView {
    
    static var delegate: ParamsViewDelegate?
    var selectedIndex: Int?

    
    @IBOutlet weak var paramKey: UILabel!
    @IBOutlet weak var paramValue: UILabel!    
    
    @IBAction func onParamsViewClick(_ sender: UIButton) {
        ParamsView.delegate?.onParamsViewClick(index: self.tag)
    }
    

}
