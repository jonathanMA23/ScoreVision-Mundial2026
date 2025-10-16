

import Foundation

// MARK: - 1. Modelo Principal (Partido)

struct Partido: Codable, Identifiable {
    // La app usará la arquitectura MVVM, así que los modelos son simples representaciones de datos.
    let id = UUID() // Útil para identificar elementos en listas de SwiftUI
    let equipoLocal: Equipo
    let equipoVisitante: Equipo
    var marcadorLocal: Int? // Opcional hasta que el partido termine/esté en curso
    var marcadorVisitante: Int?
    let fecha: String // Usaremos String por ahora, luego lo refinaremos a Date
    let estadio: String
    let estado: EstadoPartido // LIVE, FINALIZADO, PROXIMO

    // Estos datos vendrían de la IA de ScoreVision
    let prediccionIA: PrediccionIA
    // Añadimos CodingKeys para EXCLUIR 'id' del proceso de decodificación
    private enum CodingKeys: String, CodingKey {
         case equipoLocal
         case equipoVisitante
         case marcadorLocal
         case marcadorVisitante
         case fecha
         case estadio
         case estado
         case prediccionIA
         // NO incluimos 'id' aquí.
     }
        
}

enum EstadoPartido: String, Codable {
    case proximo = "Próximo"
    case enVivo = "LIVE"
    case finalizado = "Finalizado"
}

// MARK: - 2. Modelo de Equipo

struct Equipo: Codable, Identifiable {
    let id: Int
    let nombre: String
    let codigoFIFA: String // MEX, BRA, ESP, JAP
    let rankingIA: Int // Rango IA: #3 [cite: 44]
}

// MARK: - 3. Modelo de Predicción de la IA (Resultado y Justificación)

struct PrediccionIA: Codable {
    // Predicción de Marcador [cite: 17]
    let posibleResultado: String // Ej: "2-1"
    let probabilidadLocal: Double // 0.46 (46%) [cite: 75]
    let probabilidadEmpate: Double // 0.25 (25%) [cite: 77]
    let probabilidadVisitante: Double // 0.29 (29%)
    
    // Estimación de Goles por Jugador (Top 5) [cite: 19]
    let topGoleadoresEstimados: [EstimacionJugador]
    
    // Factores Clave (Justificación) [cite: 42]
    let factoresClave: [String] // Ej: ["Posesión Efectiva", "Desempeño Físico"]
}

struct EstimacionJugador: Codable, Identifiable {
    let id = UUID()
    let nombre: String // Ej: Mbappé [cite: 33]
    let golesEstimados: Double // Ej: 1.7 [cite: 33]
    let probabilidadGol: Double // Ej: 0.90 (90%) [cite: 33]
    // Añadimos CodingKeys para EXCLUIR 'id' del proceso de decodificación
    private enum CodingKeys: String, CodingKey {
        case nombre
        case golesEstimados
        case probabilidadGol
        // NO incluimos 'id' aquí.
    }
}
