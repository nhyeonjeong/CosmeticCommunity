//
//  SegmentCase.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/22.
//

import Foundation

protocol SegmentCase: CaseIterable {
    var segmentTitle: String { get }
    var segmentIdx: Int { get }
}
