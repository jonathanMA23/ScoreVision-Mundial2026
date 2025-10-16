
import SwiftUI
import Foundation
import Combine

// --- Modelo de Datos (Para previsualización y estructura) ---
// Es una buena práctica tener modelos claros para tus datos.
struct XGData: Identifiable {
    let id = UUID()
    let equipo: String
    let xG: Double
    let color: Color
}

// --- ViewModel (Simulado para el ejemplo) ---
// Mantenemos tu ViewModel pero con datos de ejemplo para que el código sea compilable.
class AnalisisViewModel: ObservableObject {
    @Published var posesionEfectiva: Int = 68
    @Published var promedioTorneo: Int = 52
    @Published var xGData: [XGData] = [
        XGData(equipo: "México", xG: 2.1, color: .green),
        XGData(equipo: "Argentina", xG: 1.4, color: .blue)
    ]
    @Published var hallazgoTendencia: String = "Alerta de Fatiga: México muestra un 15% menos de sprints en el segundo tiempo."
    @Published var justificacionTendencia: String = "Análisis basado en datos de GPS de jugadores en los últimos 3 partidos."
}
