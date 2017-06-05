//
//  Protocols.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import UIKit

protocol ParamsViewsProtocol {
    
    func setView(placeholder: String?, parrent: UIViewController, tag: Int)
    func getValue()
    func showHide()
    func hide()
}
