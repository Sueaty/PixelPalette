//
//  LibraryViewController.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/08.
//

import UIKit
import CoreData

//struct Color {
//    let name: String
//    let hexValue: String
//}

final class LibraryViewController: BaseViewController {
    // MARK:- Views
    private lazy var defaultView: DefaultView = {
        let view = DefaultView(frame: .zero,
                               type: .Library)
        view.isHidden = false
        return view
    }()
    
    // MARK:- Properties
    var colors = [NSManagedObject]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchPalette()
    }

    // MARK:- View Life Cycle
    override func setViewHierarchy() {
        super.setViewHierarchy()
        view.addSubview(defaultView)
    }
    
    // MARK:- Override
    override func setViewConstraint() {
        super.setViewConstraint()
        
        defaultView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
    
}

private extension LibraryViewController {
    
    func fetchPalette() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Color")
        
        do {
            colors = try managedContext.fetch(fetchRequest)
            colors.forEach { color in
                let name = color.value(forKey: "name") as? String
                let hex = color.value(forKey: "hexValue") as? String
                print("name: \(name) hex: \(hex)")
            }
        } catch let error as NSError {
            print("Failed to fetch. \(error) \(error.userInfo)")
        }
    }
    
}
