//
//  EditUploadViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/02.
//

import UIKit

final class EditUploadViewController: UploadViewController {

    var postData: PostModel?
    let viwModel = UploadViewModel(uploadType: .edit)
    
    override func configureView() {
        super.configureView()
        mainView.titleTextField.text = postData?.title
        mainView.contentTextView.text = postData?.content
        if let components = mainView.personalSelectButton.menu?.children {
            for item in components {
                if item.title == postData?.personalColor.rawValue {
                    mainView.personalSelectButton.isSelected = true
                }
            }
        }
        let hashTagText = postData?.hashTags.map{"#\($0)"}.joined(separator: " ")
        mainView.hashtagTextField.text = hashTagText

    }
    override func setNavigationBar() {
        let uploadButton = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
        
        let popButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(popButtonClicked))
        navigationItem.rightBarButtonItem = uploadButton
        navigationItem.leftBarButtonItem = popButton
    }
}

