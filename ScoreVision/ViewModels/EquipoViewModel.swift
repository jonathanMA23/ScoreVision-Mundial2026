import Foundation
import Combine // Importante para ObservableObject y @Published

// --- Modelos (para una estructura de datos clara) ---
// Es bueno tener un modelo para datos complejos como el jugador clave.
struct JugadorClave {
    let nombre: String
    let golesEstimados: Double
    let mejora: Double
    let probabilidadGol: Double
    let partidosRecientes: String
    let foto: String // Nombre de la imagen en tus assets
}

// --- ViewModel (Simulado para que el código compile) ---
class EquipoViewModel: ObservableObject {
    @Published var equipoNombre: String = "Brasil"
    @Published var rankingIA: Int = 1
    @Published var tendenciaRendimiento: String = "Mejorando"
    @Published var datosTendencia: [Double] = [60, 65, 75, 70, 85]
    @Published var posesionEfectiva: Int = 62
    @Published var tirosAPuerta: Int = 8
    @Published var jugadorClave = JugadorClave(
        nombre: "Rodrygo",
        golesEstimados: 0.8,
        mejora: 0.3,
        probabilidadGol: 0.65,
        partidosRecientes: "vs Argentina (1 Gol), vs Colombia (Asistencia)",
        foto: "rodrygo" // Asegúrate de tener una imagen con este nombre
    )
}

