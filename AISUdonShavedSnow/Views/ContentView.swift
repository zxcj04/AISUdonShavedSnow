//
//  ContentView.swift
//  AISUdonShavedSnow
//
//  Created by FanRende on 2021/12/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var dateRangeFetcher = DateRangeModelView()
    @StateObject var wmsLayerFetcher = WMSLayerModelView()

    @State private var activeMap: Bool = false
    @State private var startDate: Date = Date.now
    @State private var endDate: Date = Date.now
    @State private var stepChoice: Int = 0
    @State private var scheme: [Double] = [0.8, 0.9, 0.95, 0.995]
    
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false

    var place: Int {
        switch stepChoice {
        case 0:
            return 2
        default:
            return 3
        }
    }
    
    func refreshData() async {
        do {
            try await dateRangeFetcher.fetchRange()
        } catch {
            self.showAlert = true
        }
        self.startDate = dateRangeFetcher.firstDate
        self.endDate = dateRangeFetcher.lastDate
        self.stepChoice = 0
    }
    
    func getLayer() async {
        self.isLoading = true
        do {
            try await wmsLayerFetcher.fetchLayer(
                startDate: startDate.strftime("yyyy/MM/dd"), endDate: endDate.strftime("yyyy/MM/dd"), place: place, scheme: scheme
            )
        } catch {
            self.showAlert = true
        }
        self.isLoading = false
        self.activeMap = true
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Form {
                        DisclosureGroup("Start Date") {
                            DatePicker("Start Date", selection: $startDate, in: dateRangeFetcher.firstDate...endDate, displayedComponents: .date)
                        }
                        DisclosureGroup("End Date") {
                            DatePicker("End Date", selection: $endDate, in: startDate...dateRangeFetcher.lastDate, displayedComponents: .date)
                        }

                        Section("Start Date") {
                            Text(startDate.strftime("yyyy/MM/dd"))
                        }

                        Section("End Date") {
                            Text(endDate.strftime("yyyy/MM/dd"))
                        }

                        Section("Step") {
                            Picker("Step", selection: $stepChoice) {
                                Text("0.01").tag(0)
                                Text("0.001").tag(1)
                            }
                        }

                        HStack {
                            Button {
                                Task {
                                    await getLayer()
                                }
                            } label: {
                                Label("Get AIS Records", systemImage: "magnifyingglass")
                            }
                        }
                        .frame(height: 50)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .listRowBackground(Color.clear)
                    }
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .pickerStyle(.segmented)
                    .task {
                        await refreshData()
                    }
                    .refreshable {
                        await refreshData()
                    }

                    NavigationLink(isActive: $activeMap) {
                        MapView(url: wmsLayerFetcher.url, legend: wmsLayerFetcher.legend)
                            .ignoresSafeArea()
                    } label: { EmptyView() }
                }
                .navigationTitle("=烏龍麵雪花冰=")
                
                Color.white
                    .isHidden(!isLoading)
                    .ignoresSafeArea()
                    .opacity(isLoading ? 0.5: 0)
                    .overlay {
                        ProgressView()
                            .opacity(isLoading ? 1: 0)
                            .frame(width: 50, height: 50)
                            .alert("ERROR", isPresented: $showAlert) {
                                Button("ok") {}
                            } message: {
                                Text("Network Not Available")
                            }
                    }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        }
        
        self
    }
}

extension Date {
    func strftime(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    static func strptime(year: Int, month: Int, day: Int) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"

        let yearString = String(format: "%04d", year)
        let monthString = String(format: "%02d", month)
        let dayString = String(format: "%02d", day)

        let dateStr = yearString + monthString + dayString

        return formatter.date(from: dateStr) ?? Date.now
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
