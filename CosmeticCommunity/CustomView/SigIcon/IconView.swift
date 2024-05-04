//
//  IconView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/05.
//

import SnapKit
import UIKit

final class IconView: BaseView {
    let stackView = {
        let view = UIStackView()
        view.spacing = 2
        return view
    }()
    let imageView1 = UIImageView()
    let imageView2 = UIImageView()
    let imageView3 = UIImageView()
    let imageView4 = UIImageView()
    override func configureHierarchy() {
        stackView.addArrangedSubview(imageView1)
        stackView.addArrangedSubview(imageView2)
        stackView.addArrangedSubview(imageView3)
        stackView.addArrangedSubview(imageView4)
    }
    override func configureConstraints() {
        imageView1.snp.makeConstraints { make in
            // 이후에 채울 예정
        }
    }
    override func configureView() {
        configureImageView(imageView1, image: .image1)
        configureImageView(imageView2, image: .image2)
        configureImageView(imageView3, image: .image1)
        configureImageView(imageView4, image: .image2)
    }
    func configureImageView(_ view: UIImageView, image: UIImage) {
        view.image = image
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }
}
