//
//  AlternatorViewModel+MessageHandler.swift
//  
//
//  Created by Ana Márquez on 01/02/2024.
//

import CoreLocation
import UIKit
import MapKit

// MARK: - Message Handler

extension AlternatorViewModel: MessageHandler {
    
    func didReceive(_ response: CommomResponseModel) {
        if response.type == .browser {
            guard let message = response.data?.value,
                  let url = URL(string: message), UIApplication.shared.canOpenURL(url)
            else { return }
            
            debugPrint("[Alternator] Did receive url: \(message)")
            
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
            return
        }
        
        if response.type == .intercom,
           let isIntercomOpen = response.data?.setting
        {
            // Intercom have their own listener to update the view, so the keyboard changes should not happen when the keyboard its open from Intercom
            self.isIntercomOpen = isIntercomOpen
            DispatchQueue.main.async {
                self.allowKeyboardChanges = !isIntercomOpen
            }
            return
        }
        
        if response.type == .navigate,
           let latitude = response.data?.latitude,
           let longitude = response.data?.longitude
        {
            self.openMaps(with: .init(latitude: latitude, longitude: longitude), name: response.data?.operator)
            return
        }
        
        if response.type == .path,
           let path = self.savedPath?.path
        {
            // Dont use keyboard changes if we are on location details (search)
            let isLocationDetails = path.contains("/locations/")
            DispatchQueue.main.async {
                self.allowKeyboardChanges = !isLocationDetails
            }
        }
    }
    
    @MainActor
    func updateLoader(_ loading: Bool) {
        self.isLoading = loading
    }
    
    func error(_ message: String) {
        debugPrint("[Alternator] Did receive error: \(message)")
    }
    
    // MARK: - Actions
    
    private func openMaps(with coordinate: CLLocationCoordinate2D, name: String?) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        DispatchQueue.main.async {
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}
