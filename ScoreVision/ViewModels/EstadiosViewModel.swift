
import SwiftUI
import MapKit
import Combine

// --- 1. Modelo de Datos Detallado ---
// Create a more robust data structure for each stadium.
struct Estadio: Identifiable {
    let id = UUID()
    let nombre: String
    let ciudad: String
    let pais: String
    let capacidad: Int
    let imageName: String
    let coordinate: CLLocationCoordinate2D
    
    // Formats the capacity number with commas.
    var capacidadFormatted: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: capacidad)) ?? ""
    }
}

// --- 2. ViewModel (or Data Source) ---
// This class will manage the data, making your view cleaner.
class EstadiosViewModel: ObservableObject {
    @Published var estadios: [Estadio] = [
        Estadio(nombre: "Estadio Azteca", ciudad: "Mexico City", pais: "MEX", capacidad: 87523, imageName: "azteca", coordinate: .init(latitude: 19.3029, longitude: -99.1504)),
        Estadio(nombre: "MetLife Stadium", ciudad: "New Jersey", pais: "USA", capacidad: 82500, imageName: "metlife", coordinate: .init(latitude: 40.8135, longitude: -74.0745)),
        Estadio(nombre: "SoFi Stadium", ciudad: "Los Angeles", pais: "USA", capacidad: 70240, imageName: "sofi", coordinate: .init(latitude: 33.9535, longitude: -118.3392)),
        Estadio(nombre: "AT&T Stadium", ciudad: "Dallas", pais: "USA", capacidad: 80000, imageName: "att", coordinate: .init(latitude: 32.7478, longitude: -97.0929)),
        Estadio(nombre: "Mercedes-Benz Stadium", ciudad: "Atlanta", pais: "USA", capacidad: 71000, imageName: "mercedes", coordinate: .init(latitude: 33.7554, longitude: -84.4005)),
        Estadio(nombre: "BC Place", ciudad: "Vancouver", pais: "CAN", capacidad: 54500, imageName: "bcplace", coordinate: .init(latitude: 49.2767, longitude: -123.1119)),
        Estadio(nombre: "BMO Field", ciudad: "Toronto", pais: "CAN", capacidad: 45000, imageName: "bmo", coordinate: .init(latitude: 43.6328, longitude: -79.4185))
    ]
}
