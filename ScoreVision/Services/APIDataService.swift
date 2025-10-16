import Foundation

// Enum para manejar errores de la API
enum APIError: Error {
    case invalidURL
    case decodingError
    case networkError(Error)
    case apiRateLimit
}

class APIDataService {
    
    func obtenerPartidos() async throws -> [Partido] {
        try await Task.sleep(nanoseconds: 1_000_000_000)

        guard let url = Bundle.main.url(forResource: "partidos_mundial", withExtension: "json") else {
            // Lanza un error si no encuentra el archivo (deberías verlo en la consola)
            print("Error: JSON file not found in bundle.")
            throw APIError.invalidURL
        }

        let data = try Data(contentsOf: url)

        do {
            // Intenta decodificar: si falla aquí, es por un JSON mal formado.
            let partidos = try JSONDecoder().decode([Partido].self, from: data)
            return partidos
        } catch {
            // Si decodificar falla, lanza un error específico.
            print("Error de decodificación: \(error)")
            throw APIError.decodingError
        }
    }
}
