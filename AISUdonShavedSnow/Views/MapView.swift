//
//  MapView.swift
//  AISUdonShavedSnow
//
//  Created by FanRende on 2021/12/25.
//

import SwiftUI
import MapKit
import WMSKit

struct MapView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var url: String
    @State var legend: [ColorLabel]
    @State private var showLegend: Bool = false

    var body: some View {
        ZStack {
            InnerMapView(url: url)
                .onTapGesture {
                    showLegend.toggle()
                }
            
            ZStack(alignment: .bottomLeading) {
                Color.gray
                    .frame(height: 100)
                    .ignoresSafeArea()
                    .opacity(0.8)
                
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("Back", systemImage: "arrowtriangle.backward.circle.fill")
                            .font(.title2)
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .offset(y: -(UIScreen.main.bounds.height - 100) / 2)
            .offset(y: showLegend ? 0: -250)
            .animation(.easeInOut, value: showLegend)

            ZStack {
                Color.gray
                    .frame(width: 140, height: 175)
                    .cornerRadius(20)
                    .padding()
                    .shadow(radius: 5)

                VStack(alignment: .leading, spacing: 5) {
                    ForEach(legend) { l in
                        HStack {
                            l.color
                                .frame(width: 20, height: 20)
                            
                            Text(String(format: "%.0f", l.value))
                        }
                    }
                }
            }
            .offset(x: (UIScreen.main.bounds.width - 170) / 2, y: (UIScreen.main.bounds.height - 205) / 2)
            .offset(x: showLegend ? 0: 350)
            .animation(.easeInOut, value: showLegend)
        }
        .navigationBarHidden(true)
        .onAppear {
            print(legend)
        }
    }
}

public class WMSTileOverlayRenderer: MKTileOverlayRenderer {
    public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
    
    public override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        return super.canDraw(mapRect, zoomScale: zoomScale)
    }
}

struct InnerMapView: UIViewRepresentable {
    var url: String
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKTileOverlay {
                return WMSTileOverlayRenderer(overlay: overlay)
            } else {
                return WMSTileOverlayRenderer()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let overlay = WMSTileOverlay(urlArg: url, useMercator: false, wmsVersion: "1.1.1")
        
        overlay.canReplaceMapContent = false
        mapView.addOverlay(overlay, level: .aboveLabels)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    typealias UIViewType = MKMapView
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(
            url: "http://192.168.100.142:8608/geoserver/wms?service=WMS&transparent=true&format=image/png&tiled=false&version=1.1.1&request=GetMap&styles=&layers=ios_backend:e6a28d1a-e459-49af-b672-9e8d48a79f69&width=256&height=256&srs=EPSG:4326&scale=1.0",
            legend: [ColorLabel(color: Color.red, value: 10)]
        )
    }
}
