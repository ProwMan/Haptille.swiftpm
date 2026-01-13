import CoreLocation
import Foundation

@MainActor
final class LocationProvider: NSObject, ObservableObject {
    enum LocationError: Error {
        case permissionDenied
        case unavailable
    }

    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    private let manager: CLLocationManager
    private var completion: (@MainActor (Result<CLLocation, Error>) -> Void)?
    private var delegate: Delegate?

    override init() {
        manager = CLLocationManager()
        authorizationStatus = manager.authorizationStatus
        super.init()
        let delegate = Delegate(provider: self)
        self.delegate = delegate
        manager.delegate = delegate
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation(completion: @escaping @MainActor (Result<CLLocation, Error>) -> Void) {
        self.completion = completion
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            return
        case .restricted, .denied:
            self.completion = nil
            completion(.failure(LocationError.permissionDenied))
            return
        default:
            break
        }

        manager.requestLocation()
    }

    fileprivate func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        authorizationStatus = status
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            if completion != nil {
                manager.requestLocation()
            }
        case .restricted, .denied:
            if let completion {
                self.completion = nil
                completion(.failure(LocationError.permissionDenied))
            }
        default:
            break
        }
    }

    fileprivate func handleLocations(_ locations: [CLLocation]) {
        guard let location = locations.last else {
            if let completion {
                self.completion = nil
                completion(.failure(LocationError.unavailable))
            }
            return
        }

        if let completion {
            self.completion = nil
            completion(.success(location))
        }
    }

    fileprivate func handleError(_ error: Error) {
        if let completion {
            self.completion = nil
            completion(.failure(error))
        }
    }
}

private final class Delegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    weak var provider: LocationProvider?

    init(provider: LocationProvider) {
        self.provider = provider
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        let provider = self.provider
        Task { @MainActor in
            provider?.handleAuthorizationChange(status)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let provider = self.provider
        Task { @MainActor in
            provider?.handleLocations(locations)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let err = error
        let provider = self.provider
        Task { @MainActor in
            provider?.handleError(err)
        }
    }
}
