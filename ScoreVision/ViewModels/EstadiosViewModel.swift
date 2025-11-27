import SwiftUI
import MapKit
import Combine

// --- 1. Modelo de Datos Detallado ---
struct Estadio: Identifiable {
    let id = UUID()
    let nombre: String
    let ciudad: String
    let pais: String // "Canadá", "México", "Estados Unidos"
    let capacidad: Int
    let coordinate: CLLocationCoordinate2D
    
    // Propiedad computada para formatear la capacidad (ej: 87,523)
    var capacidadFormatted: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: capacidad)) ?? ""
    }
}

// --- 2. ViewModel ---
class EstadiosViewModel: ObservableObject {
    @Published var estadios: [Estadio] = []
    
    init() {
        cargarEstadios()
    }
    
    func cargarEstadios() {
        self.estadios = [
            // --- CANADÁ ---
            Estadio(nombre: "Toronto Stadium", ciudad: "Toronto, Ontario", pais: "Canadá", capacidad: 30000, coordinate: CLLocationCoordinate2D(latitude: 43.6332, longitude: -79.4186)),
            Estadio(nombre: "BC Place Vancouver", ciudad: "Vancouver, British Columbia", pais: "Canadá", capacidad: 54500, coordinate: CLLocationCoordinate2D(latitude: 49.2768, longitude: -123.1120)),
            
            // --- MÉXICO ---
            Estadio(nombre: "Estadio Azteca", ciudad: "Tlalpan, CDMX", pais: "México", capacidad: 87523, coordinate: CLLocationCoordinate2D(latitude: 19.3029, longitude: -99.1505)),
            Estadio(nombre: "Estadio Guadalajara", ciudad: "Zapopan, Jalisco", pais: "México", capacidad: 48071, coordinate: CLLocationCoordinate2D(latitude: 20.6818, longitude: -103.4626)),
            Estadio(nombre: "Estadio Monterrey", ciudad: "Guadalupe, Nuevo León", pais: "México", capacidad: 53500, coordinate: CLLocationCoordinate2D(latitude: 25.6180, longitude: -100.2493)),
            
            // --- ESTADOS UNIDOS ---
            Estadio(nombre: "Atlanta Stadium", ciudad: "Atlanta, Georgia", pais: "Estados Unidos", capacidad: 71000, coordinate: CLLocationCoordinate2D(latitude: 33.7554, longitude: -84.4010)),
            Estadio(nombre: "Boston Stadium", ciudad: "Foxborough, Massachusetts", pais: "Estados Unidos", capacidad: 65878, coordinate: CLLocationCoordinate2D(latitude: 42.0909, longitude: -71.2643)),
            Estadio(nombre: "Dallas Stadium", ciudad: "Arlington, Texas", pais: "Estados Unidos", capacidad: 80000, coordinate: CLLocationCoordinate2D(latitude: 32.7473, longitude: -97.0945)),
            Estadio(nombre: "Houston Stadium", ciudad: "Houston, Texas", pais: "Estados Unidos", capacidad: 72220, coordinate: CLLocationCoordinate2D(latitude: 29.6847, longitude: -95.4107)),
            Estadio(nombre: "Kansas City Stadium", ciudad: "Kansas City, Missouri", pais: "Estados Unidos", capacidad: 76416, coordinate: CLLocationCoordinate2D(latitude: 39.0489, longitude: -94.4839)),
            Estadio(nombre: "Los Angeles Stadium", ciudad: "Inglewood, California", pais: "Estados Unidos", capacidad: 70240, coordinate: CLLocationCoordinate2D(latitude: 33.9535, longitude: -118.3390)),
            Estadio(nombre: "San Francisco Bay Area Stadium", ciudad: "Santa Clara, California", pais: "Estados Unidos", capacidad: 68500, coordinate: CLLocationCoordinate2D(latitude: 37.4030, longitude: -121.9700)),
            Estadio(nombre: "Seattle Stadium", ciudad: "Seattle, Washington", pais: "Estados Unidos", capacidad: 69000, coordinate: CLLocationCoordinate2D(latitude: 47.5952, longitude: -122.3316)),
            Estadio(nombre: "Miami Stadium", ciudad: "Miami Gardens, Florida", pais: "Estados Unidos", capacidad: 64767, coordinate: CLLocationCoordinate2D(latitude: 25.9580, longitude: -80.2389)),
            Estadio(nombre: "New York/New Jersey Stadium", ciudad: "East Rutherford, NJ", pais: "Estados Unidos", capacidad: 82500, coordinate: CLLocationCoordinate2D(latitude: 40.8135, longitude: -74.0745)),
            Estadio(nombre: "Philadelphia Stadium", ciudad: "Philadelphia, Pennsylvania", pais: "Estados Unidos", capacidad: 67594, coordinate: CLLocationCoordinate2D(latitude: 39.9008, longitude: -75.1675))
        ]
    }
    
    // Helpers para filtrar en la vista
    func estadiosPorPais(_ pais: String) -> [Estadio] {
        return estadios.filter { $0.pais == pais }
    }
}
