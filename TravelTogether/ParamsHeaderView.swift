//
//  ParamsHeaderView.swift
//  TravelTogether
//
//  Created by Dmitry on 03.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

protocol ParamsHeaderViewDelegate {
    func onParamsHeaderViewClick(name: String, instantiateVC: UIViewController?)
}

class ParamsHeaderView: UIView {
    
    static var delegate: ParamsHeaderViewDelegate?
    
    var name: String?
    var instantiateVC: UIViewController?
    
    @IBOutlet weak var paramKey: UILabel!
    @IBOutlet weak var paramValue: UILabel!    
    
    @IBAction func onParamsHeaderViewClick(_ sender: UIButton) {
        ParamsHeaderView.delegate?.onParamsHeaderViewClick(name: name!, instantiateVC: instantiateVC)
    }
    

}
