//
//  DateRangeModelView.swift
//  AISUdonShavedSnow
//
//  Created by FanRende on 2021/12/26.
//

import Foundation

@MainActor
class DateRangeModelView: ObservableObject {
    @Published var firstDate: Date = Date.now.addingTimeInterval(-1)
    @Published var lastDate: Date = Date.now.addingTimeInterval(1)

    enum FetchError: Error {
        case badRequest
        case badJSON
    }

    @available(iOS 15.0, *)
    func fetchRange() async throws  {
        let urlStr = "http://192.168.100.141:5009/ais/dateRange"
        guard let url = URL(string: urlStr) else {return}
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        let dateRange = try JSONDecoder().decode(DateRange.self, from: data)

        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        self.firstDate = df.date(from: dateRange.firstDate)!
        self.lastDate = df.date(from: dateRange.lastDate)!
    }
}
