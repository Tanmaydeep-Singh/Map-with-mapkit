//
//  ContentView.swift
//  Maps-with-mapkit
//
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    @State private var route: MKRoute?
    
    let usersLocation = CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090)
    
    let destination = CLLocationCoordinate2D(latitude: 28.6239, longitude: 77.2290)

    var body: some View {
        Map(position: $cameraPosition) {
            
            Marker("User's Location", coordinate: usersLocation)
                .tint(.blue)
            
            Marker("Destination", coordinate: destination)
            
            if let route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            fetchRoute()
        }
    }

    func fetchRoute() {
        let request = MKDirections.Request()
        
        let sourceItem = MKMapItem(
            location: CLLocation(latitude: usersLocation.latitude, longitude: usersLocation.longitude),
            address: nil
        )
        
        let destinationItem = MKMapItem(
            location: CLLocation(latitude: destination.latitude, longitude: destination.longitude),
            address: nil
        )
        
        request.source = sourceItem
        request.destination = destinationItem
        request.transportType = .automobile

        Task {
            do {
                let directions = MKDirections(request: request)
                let response = try await directions.calculate()
                route = response.routes.first
            } catch {
                print("Failed to fetch route: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
