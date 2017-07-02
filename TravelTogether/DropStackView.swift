//
//  DropStackView.swift
//  TravelTogether
//
//  Created by Dmitry on 01.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit

class DropStackView: UIStackView, ParamsHeaderViewDelegate, ParamsSelectFieldDelegate, ParamsDatePickerDelegate, SearchTableViewDelegate {
    
    var parent: UIViewController?
    var selectedName: String?
    
    var paramsDict = [String : ParamsDropStack]() // массив вложенностей
    var headersDict = [String : ParamsHeaderView]() // массив заголовков
    
    var result = [String : AnyHashable]()
    
    func addComponents (_ components: [(header: String, paramKey: String, fields: [ParamsAbstract]?, instantiateVC: UIViewController?)]  ) {
        
        components.forEach { (component) in
            let paramsDropStack = Bundle.main.loadNibNamed("ParamsDropStack", owner: self, options: nil)?.first as! ParamsDropStack
            let headerView = Bundle.main.loadNibNamed("ParamsHeaderView", owner: self, options: nil)?.first as! ParamsHeaderView
            headerView.name = component.header
            headerView.paramKey.text = component.paramKey
            headerView.instantiateVC = component.instantiateVC
            headerView.paramValue.text = NSLocalizedString("Not filled", comment: "Not filled")
            paramsDropStack.stackView.addArrangedSubview(headerView)
            self.headersDict[component.header] = headerView
            self.paramsDict[component.header] = paramsDropStack
            component.fields?.forEach { (view) in
                paramsDropStack.stackView.addArrangedSubview(view)
            }
            self.addArrangedSubview(paramsDropStack)
        }
    }
    
    func setDropStackView(_ parent: UIViewController) {
        self.parent = parent
        ParamsHeaderView.delegate = self
        ParamsSelectField.delegate = self
        ParamsDatePicker.delegate = self
        SearchTableViewController.delegate = self
    }
    
    func getValue() -> [String : AnyHashable] {
        self.paramsDict.forEach { (component) in
            component.value.stackView.subviews.forEach { (view) in
                if let view = view as? ParamsViewsProtocol {
                    view.getValue(complition: { (name, rawValue, localValue) in
                        if rawValue != nil {
                            self.result[name!] = rawValue
                        }
                    })
                }
            }
        }
        return self.result
    }
    
    func onParamsHeaderViewClick(name: String, instantiateVC: UIViewController?) {
        self.parent!.view.endEditing(true)
        
        // Прячем все вложенности
        self.paramsDict.forEach { (component) in
            component.value.stackView.subviews.forEach { (view) in
                if let view = view as? ParamsViewsProtocol {
                    if name != self.selectedName {view.hide()}
                    view.getValue(complition: { (name, rawValue, localValue) in
                        self.headersDict.forEach { (header) in
                            if header.value.name == name {
                                if localValue != nil {
                                    header.value.paramValue.text = localValue != "" ? localValue : NSLocalizedString("Not filled", comment: "Not filled")
                                }
                            }
                        }
                    })
                }
            }
        }
        
        self.selectedName = name
        
        // Открыть закрыть вложенности
        self.paramsDict[name]?.stackView.subviews.forEach { (component) in
            if let view = component as? ParamsViewsProtocol {
                view.showHide()
            }
        }
        if let instantiateVC = instantiateVC {
            parent?.navigationController?.pushViewController(instantiateVC, animated: true)
        }
    }    
    
    // Метод делегата selectField
    func selectField(name: String, localResult: String) {
        
        // Чистим неиспользуемые результаты
        self.paramsDict[selectedName!]?.stackView.subviews.forEach { (component) in
            if let field = component as? ParamsSelectField {
                field.checkImage.isHidden = true
                if field.localResult != localResult {
                    field.rawResult = nil
                    field.localResult = nil
                }
                UIView.animate(withDuration: 0.3) {
                    field.hide()
                }
            }
        }
        
        // Назначить в хедер
        self.headersDict.forEach { (header) in
            if header.value.name == name {
                header.value.paramValue.text = localResult
            }
        }
    }
    
    // Метод делегате datePicker
    func onDoneClick(name: String, localDate: String) {
        self.headersDict.forEach { (header) in
            if header.value.name == name {
                header.value.paramValue.text = localDate
            }
        }
    }
    
    // Метод делегата поиска
    func getSearchResult(name: String?, result: (String, String)) {
        self.headersDict.forEach { (header) in
            if header.value.name == name {
                header.value.paramValue.text = result.1
                self.result[name!] = result.1
                countryId = result.0
            }
        }
    }
    
    
    
    
}
