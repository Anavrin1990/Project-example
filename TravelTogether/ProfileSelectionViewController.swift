//
//  ProfileSelectionViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 04.06.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class ProfileSelectionViewController: UIViewController {
    
    @IBOutlet weak var paramsStackView: UIStackView!
    var index: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        for _ in 0...20 {
            let paramView = Bundle.main.loadNibNamed("ParamsView", owner: self, options: nil)?.first as! ParamsView
            
            paramView.paramValue.text = NSLocalizedString("Выбрать", comment: "Выбрать")
            paramsStackView.addArrangedSubview(paramView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
