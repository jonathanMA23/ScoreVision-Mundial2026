//
//  PrtidosViewModel.swift
//  ScoreVision
//
//  Created by Danna Paola Alcantara on 14/10/25.
//

import Foundation
import Combine

// Enum for managing the filter state
enum PartidosFilter: String, CaseIterable {
    case hoy = "Hoy"
    case proximos = "Próximos"
    case finalizados = "Finalizados"
}

class PartidosViewModel: ObservableObject {
    
    @Published var partidos: [Partido] = []
    @Published var filtroSeleccionado: PartidosFilter = .hoy
    
    private let dataService = APIDataService()
    
    init() {
        Task {
            await cargarPartidos()
        }
    }
    
    @MainActor
    func cargarPartidos() async {
        let persistenceManager = DataPersistenceManager()

        do {
            let fetchedPartidos = try await dataService.obtenerPartidos()
            self.partidos = fetchedPartidos
            persistenceManager.guardarPartidosHistoricos(fetchedPartidos)
        } catch {
            print("Network error. Attempting to load from persistence...")
            self.partidos = persistenceManager.obtenerPartidosGuardados()
        }
    }
    
    // Filtered matches based on user selection
    var partidosFiltrados: [Partido] {
        switch filtroSeleccionado {
        case .hoy:
            // "Hoy" will show live matches and upcoming matches for the current date
            // For this simulation, we'll use "15 Oct" as "today"
            return partidos.filter { $0.estado == .enVivo || ($0.estado == .proximo && $0.fecha == "15 Oct") }
        case .proximos:
            return partidos.filter { $0.estado == .proximo && $0.fecha != "15 Oct" }
        case .finalizados:
            return partidos.filter { $0.estado == .finalizado }
        }
    }
    
    var partidoEnVivo: Partido? {
        return partidos.first(where: { $0.estado == .enVivo })
    }
    
    // New logic for Top Goalscorers
    var topGoleadores: [EstimacionJugador] {
        // 1. Get all of today's matches
        let partidosDeHoy = partidos.filter { $0.estado == .enVivo || ($0.estado == .proximo && $0.fecha == "15 Junio") }
        // 2. Get all goalscorer estimates from these matches into a single flat array
        let todosLosGoleadores = partidosDeHoy.flatMap { $0.prediccionIA.topGoleadoresEstimados }
        // 3. Sort by estimated goals in descending order
        let goleadoresOrdenados = todosLosGoleadores.sorted { $0.golesEstimados > $1.golesEstimados }
        // 4. Return the top 5
        return Array(goleadoresOrdenados.prefix(5))
    }
    
    var alertaDeValor: String {
        return "JAP vs. ESP - Resultado 2-1 | 50% ESP (¡Alerta Sorpresa!)"
    }
}

