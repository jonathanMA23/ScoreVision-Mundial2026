import Foundation

class IAEngine {
    
    // Este método simula el análisis de IA a partir de métricas brutas (goles, posesión, tiros)
    // En el futuro, integrarías un modelo de Machine Learning real aquí.
    static func generarPrediccion(para partido: Partido) -> PrediccionIA {
        
        // --- 1. Lógica de Predicción Simulada (Basada en los nombres) ---
        let probLocal: Double
        let probEmpate: Double
        let probVisitante: Double
        let resultado: String
        
        if partido.equipoLocal.nombre == "Brasil" {
            // Favorito -> alta probabilidad de victoria
            probLocal = 0.70
            probEmpate = 0.15
            probVisitante = 0.15
            resultado = "3-1"
        } else if partido.equipoLocal.nombre == "México" {
            // Match más parejo
            probLocal = 0.45
            probEmpate = 0.30
            probVisitante = 0.25
            resultado = "2-1"
        } else {
            // Default
            probLocal = 0.35
            probEmpate = 0.30
            probVisitante = 0.35
            resultado = "1-1"
        }
        
        // --- 2. Lógica de Goleadores Simulada (Ej. Búsqueda en una base de datos de rendimiento) ---
        let topGoles = [
            EstimacionJugador(nombre: "Jugador A", golesEstimados: 1.5, probabilidadGol: 0.85),
            EstimacionJugador(nombre: "Jugador B", golesEstimados: 0.9, probabilidadGol: 0.60)
        ]
        
        // --- 3. Lógica de Justificación Simulada ---
        let factoresClave = ["Rendimiento Histórico (\(partido.equipoLocal.rankingIA))", "Tendencia del Torneo", "Posesión Efectiva"]
        
        return PrediccionIA(
            posibleResultado: resultado,
            probabilidadLocal: probLocal,
            probabilidadEmpate: probEmpate,
            probabilidadVisitante: probVisitante,
            topGoleadoresEstimados: topGoles,
            factoresClave: factoresClave
        )
    }
}
