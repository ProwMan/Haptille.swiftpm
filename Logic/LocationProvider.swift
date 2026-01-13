import CoreLocation
import Foundation

@MainActor
final class LocationProvider: NSObject, ObservableObject {
    enum LocationError: Error {
        case denied
        case unavailable
    }

    @Published private(set) var status: CLAuthorizationStatus

    private let manager = CLLocationManager()
    private var completion: (@MainActor (Result<CLLocation, Error>) -> Void)?
    private var delegate: Delegate?

    override init() {
        status = manager.authorizationStatus
        super.init()
        delegate = Delegate(provider: self)
        manager.delegate = delegate
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation(completion: @escaping @MainActor (Result<CLLocation, Error>) -> Void) {
        self.completion = completion
        status = manager.authorizationStatus

        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            self.completion = nil
            completion(.failure(LocationError.denied))
        default:
            manager.requestLocation()
        }
    }

    fileprivate func onAuthChange(_ newStatus: CLAuthorizationStatus) {
        status = newStatus

        switch newStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if completion != nil { manager.requestLocation() }
        case .restricted, .denied:
            if let cb = completion {
                completion = nil
                cb(.failure(LocationError.denied))
            }
        default:
            break
        }
    }

    fileprivate func onLocations(_ locations: [CLLocation]) {
        guard let cb = completion else { return }
        completion = nil

        if let location = locations.last {
            cb(.success(location))
        } else {
            cb(.failure(LocationError.unavailable))
        }
    }

    fileprivate func onError(_ error: Error) {
        if let cb = completion {
            completion = nil
            cb(.failure(error))
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
        Task { @MainActor in provider?.onAuthChange(status) }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let provider = self.provider
        Task { @MainActor in provider?.onLocations(locations) }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let err = error
        let provider = self.provider
        Task { @MainActor in provider?.onError(err) }
    }
}
