//
//  HomeController.swift
//  Uber
//
//  Created by trungnghia on 5/10/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

private enum SideBarButtonConfiguration {
    case showSideMenu
    case dismissActionView
    
    init() {
        self = .showSideMenu
    }
}

private enum AnnotationType: String {
    case pickup
    case destination
}

protocol HomeControllerDelegate: class {
    func handleMenuToggle()
}


class HomeController: UIViewController {
    
    //MARK: - Properties
    weak var delegate: HomeControllerDelegate?
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private let rideActionView = RideActionView()
    
    private final let locationInputViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300
    
    var user: User? {
        didSet {
            
            // Show inputActivationView and fetch Drivers if user is passenger
            if user?.accountType == .passenger {
                print("Debug: User is passenger...")
                UIView.animate(withDuration: 2) {
                    self.inputActivationView.alpha = 1
                }
                fetchDrivers()
                observeCurrentTrip()
                configureSavedUserLocations()
            } else {
                print("Debug: User is driver...")
                inputActivationView.alpha = 0
                observeTrips()
            }
        }
    }
    
    private var trip: Trip? {
        didSet {
            guard let user = user else { return }
            if user.accountType == .driver {
                print("Debug: Show pickup passenger controller...")
                guard let trip = trip else { return }
                let controller = PickupController(trip: trip)
                controller.delegate = self
                controller.modalPresentationStyle = .fullScreen
                present(controller, animated: true, completion: nil)
            } else {
                print("Debug: Show ride action view for accepted trip...")
                guard let state = trip?.state else { return }
                guard let driverUid = trip?.driverUid else { return }
                
                switch state {
                    
                case .requested:
                    break
                    
                case .denied:
                    self.shouldPresentLoadingView(false)
                    self.showAlert(withTitle: "Opps", withMessage: "It looks like we couldn't find you a driver. Please try again...")
                    PassengerService.shared.deleteTrip { (error, ref) in
                        self.centerMapOnUserLocation()
                        self.inputActivationView.alpha = 1
                        self.configureSideBarButton(config: .showSideMenu)
                        self.removeAnnotationsAndOverlays()
                    }
                    
                case .accepted:
                    print("Debug: Trip was accepted..")
                    shouldPresentLoadingView(false)
                    removeAnnotationsAndOverlays()
                    
                    // Only zoom user and driver who taking the trip
                    zoomForActiveTrip(withDriverUid: driverUid)

                    Service.shared.fetchUserData(uid: driverUid) { (driver) in
                        self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                    }
                    
                case .driverArrived:
                    print("Debug: Driver arrived..")
                    rideActionView.config = .driverArrived
                    
                case .inProgress:
                    print("Debug: Handle inProgress..")
                    rideActionView.config = .tripInProgress
                
                case .arrivedAtDestination:
                    print("Debug: Handle arrived at destination..")
                    rideActionView.config = .endTrip
                
                case .completed:
                    print("Debug: Handle completed..")
                    PassengerService.shared.deleteTrip { (error, ref) in
                        if let error = error {
                            print("Error deleting trip, \(error.localizedDescription)")
                            self.showAlert(withMessage: error.localizedDescription)
                            return
                        }
                        self.animateRideActionView(shouldShow: false)
                        self.centerMapOnUserLocation()
                        self.configureSideBarButton(config: .showSideMenu)
                        self.inputActivationView.alpha = 1
                        self.showAlert(withTitle: "Trip Completed", withMessage: "We hope you enjoyed your trip with")
                    }
                    
                }
                
            }
        }
    }
    
    
    private var placemarks = [MKPlacemark]()
    private var route: MKRoute?
    private var savedLocations = [MKPlacemark]()
    private var saveTitleLocations = [String]()
    
    
    private var sideBarButtonConfig = SideBarButtonConfiguration()
        
    private let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icon_current_place").withRenderingMode(.alwaysOriginal), for: .normal)
        button.setDimensions(height: 24, width: 24)
        button.addTarget(self, action: #selector(handleCurrentLocation), for: .touchUpInside)
        return button
    }()
    
    private let sideBarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSideBar), for: .touchUpInside)
        return button
    }()
    
    private let liftUpActionViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "lift-up-80").withRenderingMode(.alwaysOriginal), for: .normal)
        button.setDimensions(height: 30, width: 30)
        button.addTarget(self, action: #selector(handleLiftUpActionView), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
        configureUI()
        
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Passenger API
    // https://www.udemy.com/course/programmatic-uber-clone-swift-firebase-no-storyboards/learn/lecture/17211508#overview
    private func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        showLoader(true, withText: "Updating Drivers...")
        PassengerService.shared.fetchDrivers(location: location) { (driver) in
            
            self.showLoader(false)
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            print("Debug: Driver Coordinate is \(coordinate)")
            
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false }
                    if driverAnno.uid == driver.uid {
                        print("Debug: Handle update driver position")
                        driverAnno.updateAnnotationPostion(withCoordinate: coordinate)
                        self.zoomForActiveTrip(withDriverUid: driver.uid)
                        return true
                    }
                    return false
                }
            }
            
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    
    private func observeCurrentTrip() {
        PassengerService.shared.observeCurrentTrip { (trip) in
            self.trip = trip
        }
    }
    
    private func startTrip() {
        guard let trip = trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { (error, ref) in
            if let error = error {
                print("Debug: Errow updating trip, \(error.localizedDescription)")
                self.showAlert(withMessage: error.localizedDescription)
                return
            }
            
            self.rideActionView.config = .tripInProgress
            self.removeAnnotationsAndOverlays()
            self.mapView.addAnnotationAndSelect(forCoordinate: trip.destinationCoordinates)
            
            let placemark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let destination = MKMapItem(placemark: placemark)
            self.generatePolyline(toDestination: destination)
            
            self.setCustomRegion(withType: .destination, coordinates: trip.destinationCoordinates, withRadius: 25)
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
            
        }
    }
    
    //MARK: - Driver API
    private func observeTrips() {
        DriverService.shared.observeTrips { (trip) in
            self.trip = trip
        }
    }
    
    func observeCancelledTrip(trip: Trip) {
        DriverService.shared.observeTripCanceled(trip: trip) {
            self.removeAnnotationsAndOverlays()
            self.animateRideActionView(shouldShow: false)
            self.centerMapOnUserLocation()
            self.showAlert(withTitle: "Trip Rejected", withMessage: "The Passenger has cancelled this trip. Press OK to continue.")
        }
    }
    
    //MARK: - Helpers
    private func configureUI() {
        configureMapView()
        inputActivationView.delegated = self
        
        view.addSubview(sideBarButton)
        sideBarButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 5, paddingLeft: 16, width: 30, height: 30)
        
        
        view.addSubview(currentLocationButton)
        currentLocationButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right:view.rightAnchor, paddingTop: 5, paddingRight: 12)
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.anchor(top: sideBarButton.bottomAnchor, paddingTop: 32)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.layer.cornerRadius = 5
        inputActivationView.alpha = 0 // Set default alpha = 0
        
        configureTableView() // Add tableview out of side (0: view.frame.height) in the beginning
        configureRideActionView() // Add rideActionView out of side (0: view.frame.height) in the beginning
    }
    
    private func configureMapView() {
        mapView.delegate = self // Delegate for MKMapViewDelegate
        
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    private func configureSavedUserLocations() {
        guard let user = user else { return }
        savedLocations.removeAll()
        saveTitleLocations.removeAll()
        // FIXME: todo improve
        
        if let home = user.homeLocation {
            self.saveTitleLocations.append("Home - " + home.title)
            self.geocoderAddressString(address: home.address)
        }
        
        if let work = user.workLocation {
            self.saveTitleLocations.append("Work - " + work.title)
            self.geocoderAddressString(address: work.address)
        }
        tableView.reloadData()
    }
    
    // translate from addressString to CLPlacemark
    func geocoderAddressString(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let clplacemark = placemarks?.first else { return }
            
            let placemark = MKPlacemark(placemark: clplacemark)
            self.savedLocations.append(placemark)
            self.logger(withDebug: "Count of savedLocation is \(self.savedLocations.count)")
            self.tableView.reloadData()
        }
        print("something...")
        
        
    }
    
    private func configureLocationInputView() {
        locationInputView.delegate = self
        locationInputView.user = user
        
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { (_) in
            print("Debug: Present table view...")
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView() // Remove empty cells
        
        let frameHeight = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height,
                                 width: view.frame.width, height: frameHeight)
        
        view.addSubview(tableView)
    }
    
    private func dismissLocationInputView(completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height // return original location for table view
            self.locationInputView.removeFromSuperview() //Remove locationInputView
        }, completion: completion)
    }
    
    private func configureSideBarButton(config: SideBarButtonConfiguration) {
        switch config {
            
        case .showSideMenu:
            sideBarButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            sideBarButtonConfig = .showSideMenu
        case .dismissActionView:
            sideBarButton.setImage(#imageLiteral(resourceName: "back_button").withRenderingMode(.alwaysOriginal), for: .normal)
            sideBarButtonConfig = .dismissActionView
        }
    }
    
    private func configureRideActionView() {
        rideActionView.frame = CGRect(x: 0, y: view.frame.height,
                                      width: view.frame.width, height: rideActionViewHeight)
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        
    }
    
    private func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil,
                                       config: RideActionViewConfiguration? = nil, user: User? = nil ) {
        let yOrigin = shouldShow ? (view.frame.height - rideActionViewHeight) : view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {

            if let destination = destination {
                rideActionView.destination = destination
            }
            
            if let user = user {
                rideActionView.user = user
            }
            
            if let config = config {
                rideActionView.config = config
            }
        }

    }
    
    
    //MARK: - Selectors
    @objc func handleCurrentLocation() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    @objc func handleSideBar() {
        switch sideBarButtonConfig {
            
        case .showSideMenu:
            print("Debug: Handle show side menu...")
            delegate?.handleMenuToggle()
            
        case .dismissActionView:
            print("Debug: Handle dismiss action view...")
            
            removeAnnotationsAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            UIView.animate(withDuration: 0.3) {
                self.configureSideBarButton(config: .showSideMenu)
                self.inputActivationView.alpha = 1
                self.animateRideActionView(shouldShow: false)
                self.liftUpActionViewButton.removeFromSuperview()
            }

        }
    }
    
    @objc func handleLiftUpActionView() {
        liftUpActionViewButton.removeFromSuperview()
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = self.view.frame.height - self.rideActionViewHeight
        }
    }
    
}

//MARK: - Map Helper functions
private extension HomeController {
    func searchBy(naturalLanguageQuery: String, completion: @escaping(Error?, [MKPlacemark]) -> Void) {
        var result = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let error = error {
                print("Debug: Error getting local search, \(error.localizedDescription)")
                completion(error, result)
                return
            }
            
            guard let response = response else { return }
            response.mapItems.forEach { (mapItem) in
                result.append(mapItem.placemark)
            }
            completion(error, result)
        }
    }
    
    func generatePolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            if let error = error {
                print("Debug: Error getting direction, \(error.localizedDescription)")
                return
            }
            
            guard let response = response else { return }
            self.route = response.routes.first
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationsAndOverlays() {
        // Remove annotation
        mapView.annotations.forEach { (annotation) in
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
        
        // Remove Polyline
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func setCustomRegion(withType type: AnnotationType  ,coordinates: CLLocationCoordinate2D, withRadius radius: CLLocationDistance) {
        let region = CLCircularRegion(center: coordinates, radius: radius, identifier: type.rawValue)
        locationManager?.startMonitoring(for: region)
        //print("Debug: Did set region  \(region)")
    }
    
    func zoomForActiveTrip(withDriverUid uid: String) {
        var annotations = [MKAnnotation]()
        
        mapView.annotations.forEach { (annotation) in
            if let driverAnno = annotation as?  DriverAnnotation {
                if driverAnno.uid == uid {
                    annotations.append(driverAnno)
                }
            }
            
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
        }
        
        mapView.zoomToFit(annotations: annotations)
    }
    
}

//MARK: - LocationService
extension HomeController {
    
    func enableLocationServices() {
        // Need this to activate didStartMonitoringFor
        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("Debug: Not determined...")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("Debug: Auth always...")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("Debug: Auth when in use...")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
}

//MARK: - CLLocationManagerDelegate
extension HomeController: CLLocationManagerDelegate {
    
    // Need this to start monitoring
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            print("Debug: Did start monitoring for pickup region \(region)")
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            print("Debug: Did start monitoring for destination region \(region)")
        }
    }
    
    // Start when user enter into region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Debug: Driver did enter passenger region..")
        guard let trip = trip else { return }
        
        // Update state
        if region.identifier == AnnotationType.pickup.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: TripState.driverArrived) { (error, ref) in
                if let error = error {
                    print("Error updating trip state, \(error.localizedDescription)")
                    self.showAlert(withMessage: error.localizedDescription)
                    return
                }
                self.rideActionView.config = .pickupPassenger
                print("Debug: Update state to driverArrived..")
            }
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: TripState.arrivedAtDestination) { (error, ref) in
                if let error = error {
                    print("Error updating trip state, \(error.localizedDescription)")
                    self.showAlert(withMessage: error.localizedDescription)
                    return
                }
                self.rideActionView.config = .endTrip
                print("Debug: Update state to driverArrived..")
            }
        }
       
        
        
    }
}


//MARK: - LocationInputActivationViewDelegate
extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0 // Hide inputActivationView if tapping 
        configureLocationInputView()
    }
}

//MARK: - LocationInputViewDelegate
extension HomeController: LocationInputViewDelegate {
    func executeSearch(withQuery query: String) {
        print("Debug: Query text is \(query)")
        showLoader(true, withText: "Searching...")
        searchBy(naturalLanguageQuery: query) { (error, placemarks) in
            self.showLoader(false)
            if let error = error {
                self.showAlert(withMessage: error.localizedDescription)
                return
            }
            self.placemarks = placemarks
            self.tableView.reloadData()
        }
    }
    
    func dismisLocationInputView() {
        dismissLocationInputView { (_) in
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Saved Locations" : "Search Results"
    }
    
    // Divide table view into 2 sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? savedLocations.count : placemarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        cell.accessoryType = .disclosureIndicator
        
        if indexPath.section == 0 {
            cell.savedTitle = saveTitleLocations[indexPath.row]
            cell.savedPlacemarkAdress = savedLocations[indexPath.row]
        }
        
        if indexPath.section == 1 {
            cell.placemark = placemarks[indexPath.row]
        }
        
        return cell
    }
    
    // Do action when tapping the table cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark =  indexPath.section == 0 ? savedLocations[indexPath.row] : placemarks[indexPath.row]
        var annotations = [MKAnnotation]()
        
        configureSideBarButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        dismissLocationInputView { (_) in

            self.mapView.addAnnotationAndSelect(forCoordinate: selectedPlacemark.coordinate)
            
            self.mapView.annotations.forEach { (annotation) in
                if let annotation = annotation as? MKUserLocation {
                    annotations.append(annotation)
                }
                
                if let annotation = annotation as? MKPointAnnotation {
                    annotations.append(annotation)
                }
            }
            
            // Can use "annotations" instead of this
            let annos = self.mapView.annotations.filter( { !$0.isKind(of: DriverAnnotation.self) } )
            //self.mapView.showAnnotations(annos, animated: true)
            self.mapView.zoomToFit(annotations: annos)
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark, config: .requestRide)
            
            
        }
        
    }
    
    
}

//MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate {
    
    // Need to update user location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        // Make sure only update location for driver
        guard let user = user else { return }
        guard user.accountType == .driver else { return }
        guard let location = userLocation.location else { return }
        DriverService.shared.updateDriverLocation(location: location)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "icons8-marker-80")
            return view
        }
        
        return nil
    }
    
    // Need to add polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKPolylineRenderer()
    }
}

//MARK: - RideActionViewDelegate
extension HomeController: RideActionViewDelegate {
    func dropOffPassenger() {
        guard let trip = self.trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .completed) { (error, ref) in
            if let error = error {
                print("Debug: Error canceling trip, \(error.localizedDescription)")
                self.showAlert(withMessage: error.localizedDescription)
                return
            }
            
            self.removeAnnotationsAndOverlays()
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
        }
    }
    
    func pickupPassenger() {
        startTrip()
    }
    
    func cancelTrip() {
        showLoader(true, withText: "Canceling...")
        PassengerService.shared.deleteTrip { (error, ref) in
            self.showLoader(false)
            if let error = error {
                print("Debug: Error canceling trip, \(error.localizedDescription)")
                self.showAlert(withMessage: error.localizedDescription)
                return
            }
            
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationsAndOverlays()
            self.sideBarButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.sideBarButtonConfig = .showSideMenu
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.centerMapOnUserLocation()
            }
        }
    }
    
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.location?.coordinate else { return }
        
        shouldPresentLoadingView(true, message: "Finding you a ride...")
        
        PassengerService.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, ref) in

            if let error = error {
                print("Debug: Error uploading trip, \(error.localizedDescription)")
                return
            }
            print("Debug: Upload trip successfully...")
            
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
        }
    }
    
    
    func dropDownRideActionView() {
        print("Debug: DropDown button pressed...")
        UIView.animate(withDuration: 0.3, animations: {
            self.rideActionView.frame.origin.y = self.view.frame.height
        }) { (_) in
            UIView.animate(withDuration: 0.3) {
                self.view.addSubview(self.liftUpActionViewButton)
                self.liftUpActionViewButton.anchor(bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.rightAnchor,
                                                   paddingBottom: 8, paddingRight: 8)
            }
        }

    }
     
}

//MARK: - PickupControllerDelegate
extension HomeController: PickupControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        self.trip = trip
        
        mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
        
        // Set a region with radius, and notify if the passenger entered the region
        setCustomRegion(withType: .pickup, coordinates: trip.pickupCoordinates, withRadius: 25)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        
        // Add observe Trip cancelled
        observeCancelledTrip(trip: trip)
        
        self.dismiss(animated: true) {
            Service.shared.fetchUserData(uid: trip.passengerUid) { (passenger) in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            }
            
        }
    }
    
    
}


