//
//  LibraryViewController.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/08.
//

import UIKit

class LibraryViewController: BaseViewController {
    
    private lazy var defaultView: DefaultView = {
        let view = DefaultView(frame: .zero,
                               type: .Library)
        view.isHidden = false
        return view
    }()

    override func setViewHierarchy() {
        super.setViewHierarchy()
        view.addSubview(defaultView)
    }
    
    override func setViewConstraint() {
        super.setViewConstraint()
        
        defaultView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
    
}
