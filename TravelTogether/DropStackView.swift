//
//  DropStackView.swift
//  TravelTogether
//
//  Created by Dmitry on 01.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class DropStackView: UIStackView, ParamsHeaderViewDelegate {
    
    var parent: UIViewController?
    var selectedIndex: Int?
    
    var paramsArray = [ParamsDropStack]() // массив вложенностей
    var headersArray = [ParamsHeaderView]() // массив заголовков
    
    func addComponents (_ components: [(String, [ParamsAbstract])] ) {
        
        components.enumerated().forEach { (component) in
            let paramsDropStack = Bundle.main.loadNibNamed("ParamsDropStack", owner: self, options: nil)?.first as! ParamsDropStack
            let headerView = Bundle.main.loadNibNamed("ParamsHeaderView", owner: self, options: nil)?.first as! ParamsHeaderView
            headerView.tag = component.offset
            headerView.paramKey.text = component.element.0
            headerView.paramValue.text = NSLocalizedString("Not filled", comment: "Not filled")
            paramsDropStack.stackView.addArrangedSubview(headerView)
            self.headersArray.append(headerView)
            self.paramsArray.append(paramsDropStack)
            component.element.1.forEach { (view) in
                paramsDropStack.stackView.addArrangedSubview(view)
            }
            self.addArrangedSubview(paramsDropStack)
        }
    }
    
    func setDropStackView(_ parent: UIViewController) {
        self.parent = parent
        ParamsHeaderView.delegate = self
    }
    
    func onParamsHeaderViewClick(index: Int) {
        
        // Прячем все вложенности
        self.paramsArray.forEach { (component) in
            component.stackView.subviews.forEach { (view) in
                if let view = view as? ParamsViewsProtocol {
                    if index != self.selectedIndex {
                        view.hide()
                    }
                    view.getValue()
                }
            }
        }
        
        // Назначаем выбранное значение в заголовок
        self.headersArray.enumerated().forEach { (header) in
            let text = Person.profileDict[header.offset]?.1
            if text != "" && text != nil {
                header.element.paramValue.text = text
            }
        }
        
        self.selectedIndex = index
        
        // Открыть закрыть вложенности
        self.paramsArray[index].stackView.subviews.forEach { (component) in
            if let view = component as? ParamsViewsProtocol {
                view.showHide()
            }
        }
    }

}
