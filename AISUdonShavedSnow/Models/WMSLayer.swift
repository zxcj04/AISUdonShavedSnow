//
//  WMSLayer.swift
//  AISUdonShavedSnow
//
//  Created by FanRende on 2021/12/26.
//

import Foundation

struct WMSLayer: Decodable {
    let layer: String
    let color: [String: [Double]]
}
