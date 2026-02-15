//
//  ContentView.swift
//  Maps-with-mapkit
//
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    @State private var destination = CLLocationCoordinate2D(
        latitude: 28.7041,
        longitude: 77.1025
    )
    
    @State private var route: MKRoute?

    var body: some View {
        
        Map(position: $cameraPosition) {
            
            // User location (blue dot)
            UserAnnotation()
            
            // Destination marker
            Marker("Destination", coordinate: destination)
            
            // Route polyline
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }
        }
        .ignoresSafeArea()
        .onReceive(locationManager.$userLocation) { location in
            
            guard let location else { return }
            
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.01,
                        longitudeDelta: 0.01
                    )
                )
            )
            
            let newDestination = CLLocationCoordinate2D(
                latitude: location.latitude + 0.01,
                longitude: location.longitude + 0.01
            )
            
            destination = newDestination
            
            Task {
                fetchRoute(usersLocation: location)
            }
            
           
        }
    }
    
    func fetchRoute(usersLocation : CLLocationCoordinate2D) {
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
