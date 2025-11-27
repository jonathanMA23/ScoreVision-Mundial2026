import Foundation
import SwiftUI
import Combine
// Modelos de datos para las gráficas
struct MomentumPoint: Identifiable {
    let id = UUID()
    let minute: Int
    let strength: Double // Valor de -100 (Dominio Total Visitante) a 100 (Dominio Total Local)
}

struct StatComparison: Identifiable {
    let id = UUID()
    let metric: String // Ej: "xG", "Tiros", "Pases"
    let localValue: Double
    let visitValue: Double
    let maxScale: Double // Para normalizar la barra
}

struct InsightIA: Identifiable {
    let id = UUID()
    let tipo: String // "Alerta", "Oportunidad", "Dato"
    let mensaje: String
    let icon: String
    let color: Color
}

class AnalisisViewModel: ObservableObject {
    @Published var momentumData: [MomentumPoint] = []
    @Published var statsComparison: [StatComparison] = []
    @Published var insights: [InsightIA] = []
    
    init() {
        generateMockData()
    }
    
    func generateMockData() {
        // 1. Simulación de Momentum (Curva de dominio del partido)
        // Imagina que el valor positivo es México y negativo el rival
        self.momentumData = stride(from: 0, to: 95, by: 5).map { min in
            // Generamos una curva algo aleatoria pero suavizada
            MomentumPoint(minute: min, strength: Double.random(in: -40...80))
        }
        
        // 2. Comparativa de Estadísticas Clave
        self.statsComparison = [
            StatComparison(metric: "Goles Esp. (xG)", localValue: 2.1, visitValue: 0.9, maxScale: 3.0),
            StatComparison(metric: "Posesión %", localValue: 58, visitValue: 42, maxScale: 100),
            StatComparison(metric: "Pases Completos", localValue: 412, visitValue: 305, maxScale: 500),
            StatComparison(metric: "Presión Alta", localValue: 18, visitValue: 12, maxScale: 25)
        ]
        
        // 3. Hallazgos de la IA
        self.insights = [
            InsightIA(tipo: "ALERTA TÁCTICA", mensaje: "El rival deja espacios a la espalda del lateral derecho.", icon: "exclamationmark.triangle.fill", color: .orange),
            InsightIA(tipo: "RENDIMIENTO", mensaje: "México ha ganado el 85% de los duelos aéreos en el área.", icon: "arrow.up.circle.fill", color: .green),
            InsightIA(tipo: "FATIGA", mensaje: "El mediocampo muestra una caída de intensidad del 15%.", icon: "battery.25", color: .red)
        ]
    }
}
