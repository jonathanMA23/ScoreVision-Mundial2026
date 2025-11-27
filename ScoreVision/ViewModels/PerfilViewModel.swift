import SwiftUI
import Combine

// --- 1. Modelos de Datos ---
// Un modelo claro para el equipo. Hashable es útil para usar con Sets.
struct EquipoPerfil: Identifiable, Hashable {
    let id = UUID()
    let nombre: String
    let flagImageName: String
}

// --- VIEWMODEL PARA LA LÓGICA DEL PERFIL (CORREGIDO) ---
class PerfilViewModel: ObservableObject {
    @Published var equiposDisponibles: [EquipoPerfil] = [
        .init(nombre: "México", flagImageName: "Mexico"), // Asegúrate de que los nombres coincidan con tus assets o URL lógica
        .init(nombre: "Argentina", flagImageName: "Argentina"),
        .init(nombre: "Brasil", flagImageName: "Brazil"),
        .init(nombre: "EE. UU.", flagImageName: "USA"),
        .init(nombre: "Alemania", flagImageName: "Germany")
    ]
    
    // Usamos un Set de los IDs de los equipos para gestionar los favoritos.
    @Published var favoritasIDs: Set<UUID> = []
    
    @Published var notificacionesActivadas: Bool = true

    // Función para añadir o quitar un favorito.
    func toggleFavorito(equipo: EquipoPerfil) {
        if favoritasIDs.contains(equipo.id) {
            favoritasIDs.remove(equipo.id)
        } else {
            favoritasIDs.insert(equipo.id)
        }
    }
    
    // Propiedad computada para obtener los nombres de los equipos favoritos.
    var nombresFavoritos: String {
        let equiposFavoritos = equiposDisponibles.filter { favoritasIDs.contains($0.id) }
        if equiposFavoritos.isEmpty { return "Ninguno" }
        return equiposFavoritos.map { $0.nombre }.sorted().joined(separator: ", ")
    }
}
