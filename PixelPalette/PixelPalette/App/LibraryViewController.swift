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
    private lazy var defaultView: DefaultView = {
        let view = DefaultView(frame: .zero,
                               type: .Library)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
        flowlayout.minimumLineSpacing = 8
        flowlayout.minimumInteritemSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flowlayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(LibraryCell.self,
                                forCellWithReuseIdentifier: LibraryCell.identifier)
        collectionView.register(TitleHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleHeaderView.identifier)
        return collectionView
    }()
    
    // MARK:- Properties
    var colors = [NSManagedObject]()

    // MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchPalette()
        collectionView.reloadData()
        if !colors.isEmpty {
            defaultView.removeFromSuperview()
        }
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK:- Override Functions
    override func setViewHierarchy() {
        super.setViewHierarchy()
        
        view.addSubview(defaultView)
        view.addSubview(collectionView)
    }
    
    override func setViewConstraint() {
        super.setViewConstraint()
        
        defaultView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
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
            let results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                colors = results
            }
        } catch let error as NSError {
            print("Failed to fetch. \(error) \(error.userInfo)")
        }
    }
    
}

extension LibraryViewController: SingleColorDelegate {
    
    func didEditColorName(_ viewController: SingleColorViewController, didEditName to: String) {
        fetchPalette()
        collectionView.reloadData()
    }
    
    func didDeleteeColor(_ viewController: SingleColorViewController, deletedColor name: String) {
        fetchPalette()
        collectionView.reloadData()
    }

}

extension LibraryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let managedColor = colors[indexPath.item]
        let name = managedColor.value(forKey: "name") as? String
        let hexValue = managedColor.value(forKey: "hexValue") as? String
        let color = PaletteColor(name: name ?? "",
                                 hex: hexValue ?? "#FFFFFF")
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryCell.identifier,
                                                         for: indexPath) as? LibraryCell {
            cell.compose(data: color)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let colorViewController = storyboard?.instantiateViewController(identifier: "SingleColorVC") as? SingleColorViewController else { return }
        colorViewController.modalPresentationStyle = .automatic
        
        let managedColor = colors[indexPath.item]
        let name = managedColor.value(forKey: "name") as? String
        let hexValue = managedColor.value(forKey: "hexValue") as? String
        let uicolor = UIColor.init(hexString: hexValue ?? "#FFFFFF")
        let colorModel = PaletteColor(name: name ?? "undefined",
                                      hex: hexValue ?? "#FFFFFF",
                                      color: uicolor)
        colorViewController.delegate = self
        colorViewController.compose(data: colorModel)
        
        present(colorViewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                withReuseIdentifier: TitleHeaderView.identifier,
                                                                                for: indexPath)
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
}

extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 38) / 2 , height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0)
    }
    
}
