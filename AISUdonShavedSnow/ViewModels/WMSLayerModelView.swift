//
//  WMSLayerModelView.swift
//  AISUdonShavedSnow
//
//  Created by FanRende on 2021/12/26.
//

import Foundation
import SwiftUI

struct ColorLabel: Identifiable {
    let color: Color
    let value: Double
    
    let id = UUID()    
}

@MainActor
class WMSLayerModelView: ObservableObject {
    @Published var layer: String = ""
    @Published var legend = [ColorLabel]()
    
    var url: String {
        return "http://192.168.100.142:8608/geoserver/wms?service=WMS&transparent=true&format=image/png&tiled=false&version=1.1.1&request=GetMap&styles=&layers=\(self.layer)&width=256&height=256&srs=EPSG:4326&scale=1.0"
    }
    
    enum FetchError: Error {
        case badRequest
        case badJSON
    }

    @available(iOS 15.0, *)
    func fetchLayer(startDate: String, endDate: String, place: Int, scheme: [Double]) async throws  {
        let urlStr = "http://192.168.100.141:5009/ais/read"
        guard let fetchUrl = URL(string: urlStr) else {return}
        
        let body: [String: Any] = ["startDate": startDate, "endDate": endDate, "place": place, "scheme": scheme]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: fetchUrl)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60 * 7

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }

        let decoder = JSONDecoder()
        let wmsLayer = try decoder.decode(WMSLayer.self, from: data) as WMSLayer
        self.layer = wmsLayer.layer
        self.legend = [ColorLabel]()

        for (value, color) in wmsLayer.color {
            if color.count == 3 {
                self.legend.append(ColorLabel(
                    color: Color(red: color[0] / 255, green: color[1] / 255, blue: color[2] / 255),
                    value: Double(value)!
                ))
            }
        }
        
        self.legend.sort { label0, label1 in
            label0.value < label1.value
        }
    }
}
