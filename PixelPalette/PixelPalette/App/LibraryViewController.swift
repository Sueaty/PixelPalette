//
//  LibraryViewController.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/08.
//

import UIKit
import CoreData

final class LibraryViewController: BaseViewController {
    
    // MARK:- Views
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Palette"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var defaultView: DefaultView = {
        let view = DefaultView(frame: .zero,
                               type: .Library)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
        flowlayout.minimumLineSpacing = 0
        flowlayout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flowlayout)
        collectionView.showsVerticalScrollIndicator = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // register cell
        return collectionView
    }()
    
    // MARK:- Properties
    var colors = [NSManagedObject]() 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchPalette()
        if !colors.isEmpty {
            defaultView.removeFromSuperview()
        }
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

extension LibraryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
}

extension LibraryViewController: UICollectionViewDelegate {
    
}

extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    
}
