//
//  ViewController.swift
//  PublishLocation
//
//  Created by Esteban Herrera on 11/16/17.
//  Copyright © 2017 Esteban Herrera. All rights reserved.
//

import UIKit

import CoreLocation
import PusherSwift

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var latitude: UILabel!
    @IBOutlet var longitude: UILabel!
    @IBOutlet var heading: UILabel!
    
    let locationManager = CLLocationManager()
    var userHeading = 0.0

    let pusher = Pusher(
        key: "YOUR_PUSHER_APP_KEY",
        options: PusherClientOptions(
            authMethod: .inline(secret: "YOUR_PUSHER_APP_SECRET"),
            host: .cluster("YOUR_PUSHER_APP_CLUSTER")
        )
    )
    var channel: PusherChannel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 2.0
        locationManager.requestWhenInUseAuthorization()
        
        // subscribe to channel and connect
        channel = pusher.subscribe("private-channel")
        pusher.connect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - CLLocationManager
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if (newHeading.headingAccuracy < 0) {
            return
        }
        
        // Use the true heading if it is valid
        self.userHeading = ((newHeading.trueHeading > 0) ?
            newHeading.trueHeading : newHeading.magneticHeading)
        
        heading.text = String(self.userHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        latitude.text = String(location.coordinate.latitude)
        longitude.text = String(location.coordinate.longitude)
        
        sendPusherEvent(location);
    }
    
    //MARK: - Pusher
    
    func sendPusherEvent(_ location: CLLocation) {
        channel.trigger(eventName: "client-new-location",
            data: [
                "latitude": String(location.coordinate.latitude),
                "longitude": String(location.coordinate.longitude),
                "heading": String(self.userHeading)
            ]
        )
    }

}

