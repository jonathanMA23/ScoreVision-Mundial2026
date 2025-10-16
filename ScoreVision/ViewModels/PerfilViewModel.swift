import SwiftUI
import Combine

import SwiftUI

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
        .init(nombre: "México", flagImageName: "mexico_flag"),
        .init(nombre: "Argentina", flagImageName: "argentina_flag"),
        .init(nombre: "Brasil", flagImageName: "brazil_flag"),
        .init(nombre: "EE. UU.", flagImageName: "usa_flag"),
        .init(nombre: "Alemania", flagImageName: "germany_flag")
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
        return equiposFavoritos.map { $0.nombre }.sorted().joined(separator: ", ")
    }
}
