import Foundation
import Combine

struct CandidatoMundial: Identifiable {
    let id = UUID()
    let ranking: Int
    let nombre: String
    let probabilidadGanar: Double
    let tendencia: String // "subiendo", "bajando", "igual"
}

class EquipoViewModel: ObservableObject {
    @Published var candidatos: [CandidatoMundial] = []
    
    init() {
        cargarCandidatos()
    }
    
    func cargarCandidatos() {
        // Lista expandida de equipos clasificados/candidatos
        self.candidatos = [
            // --- Top 30 (Datos Proporcionados) ---
                CandidatoMundial(ranking: 1, nombre: "Francia", probabilidadGanar: 0.185, tendencia: "igual"),
                CandidatoMundial(ranking: 2, nombre: "Argentina", probabilidadGanar: 0.152, tendencia: "subiendo"),
                CandidatoMundial(ranking: 3, nombre: "Inglaterra", probabilidadGanar: 0.128, tendencia: "bajando"),
                CandidatoMundial(ranking: 4, nombre: "España", probabilidadGanar: 0.110, tendencia: "igual"),
                CandidatoMundial(ranking: 5, nombre: "Brasil", probabilidadGanar: 0.095, tendencia: "subiendo"),
                CandidatoMundial(ranking: 6, nombre: "Alemania", probabilidadGanar: 0.082, tendencia: "igual"),
                CandidatoMundial(ranking: 7, nombre: "Portugal", probabilidadGanar: 0.065, tendencia: "bajando"),
                CandidatoMundial(ranking: 8, nombre: "Colombia", probabilidadGanar: 0.041, tendencia: "subiendo"),
                CandidatoMundial(ranking: 9, nombre: "Países Bajos", probabilidadGanar: 0.038, tendencia: "igual"),
                CandidatoMundial(ranking: 10, nombre: "Uruguay", probabilidadGanar: 0.032, tendencia: "bajando"),
                CandidatoMundial(ranking: 11, nombre: "USA", probabilidadGanar: 0.028, tendencia: "subiendo"),
                CandidatoMundial(ranking: 12, nombre: "Croacia", probabilidadGanar: 0.021, tendencia: "bajando"),
                CandidatoMundial(ranking: 13, nombre: "Noruega", probabilidadGanar: 0.019, tendencia: "subiendo"),
                CandidatoMundial(ranking: 14, nombre: "Bélgica", probabilidadGanar: 0.018, tendencia: "bajando"),
                CandidatoMundial(ranking: 15, nombre: "Japón", probabilidadGanar: 0.015, tendencia: "subiendo"),
                CandidatoMundial(ranking: 16, nombre: "Marruecos", probabilidadGanar: 0.014, tendencia: "igual"),
                CandidatoMundial(ranking: 17, nombre: "México", probabilidadGanar: 0.012, tendencia: "bajando"),
                CandidatoMundial(ranking: 18, nombre: "Egipto", probabilidadGanar: 0.011, tendencia: "bajando"),
                CandidatoMundial(ranking: 19, nombre: "Senegal", probabilidadGanar: 0.010, tendencia: "igual"),
                CandidatoMundial(ranking: 20, nombre: "Suiza", probabilidadGanar: 0.009, tendencia: "igual"),
                CandidatoMundial(ranking: 21, nombre: "Ecuador", probabilidadGanar: 0.008, tendencia: "subiendo"),
                CandidatoMundial(ranking: 22, nombre: "Corea del Sur", probabilidadGanar: 0.007, tendencia: "igual"),
                CandidatoMundial(ranking: 23, nombre: "Canadá", probabilidadGanar: 0.006, tendencia: "subiendo"),
                CandidatoMundial(ranking: 24, nombre: "Irán", probabilidadGanar: 0.005, tendencia: "bajando"),
                CandidatoMundial(ranking: 25, nombre: "Australia", probabilidadGanar: 0.004, tendencia: "igual"),
                CandidatoMundial(ranking: 26, nombre: "Paraguay", probabilidadGanar: 0.004, tendencia: "bajando"),
                //CandidatoMundial(ranking: 27, nombre: "Serbia", probabilidadGanar: 0.003, tendencia: "igual"),
                CandidatoMundial(ranking: 27, nombre: "Arabia Saudita", probabilidadGanar: 0.003, tendencia: "subiendo"),
                CandidatoMundial(ranking: 28, nombre: "Ghana", probabilidadGanar: 0.002, tendencia: "bajando"),
                //CandidatoMundial(ranking: 30, nombre: "Dinamarca", probabilidadGanar: 0.002, tendencia: "igual"),
                
                // --- Resto de clasificados (Datos inferidos según descripción) ---
                CandidatoMundial(ranking: 29, nombre: "Argelia", probabilidadGanar: 0.002, tendencia: "subiendo"),
                //CandidatoMundial(ranking: 32, nombre: "Nigeria", probabilidadGanar: 0.001, tendencia: "igual"), // Mencionado indirectamente (gigante eliminado por Sudáfrica? No, Sudáfrica clasificó sobre él, pero a veces entran en repechaje. Si no clasificó, ignorar. Asumiré Sudáfrica en su lugar).
                
                // Corrección basada en el texto: Sudáfrica clasificó directo, Nigeria no se menciona como clasificado explícito.
                CandidatoMundial(ranking: 30, nombre: "Sudáfrica", probabilidadGanar: 0.001, tendencia: "subiendo"),
                CandidatoMundial(ranking: 31, nombre: "Costa de Marfil", probabilidadGanar: 0.001, tendencia: "igual"),
                CandidatoMundial(ranking: 32, nombre: "Panamá", probabilidadGanar: 0.001, tendencia: "igual"),
                CandidatoMundial(ranking: 33, nombre: "Túnez", probabilidadGanar: 0.001, tendencia: "igual"),
                CandidatoMundial(ranking: 34, nombre: "Uzbekistán", probabilidadGanar: 0.001, tendencia: "igual"),
                CandidatoMundial(ranking: 35, nombre: "Austria", probabilidadGanar: 0.001, tendencia: "subiendo"),
                CandidatoMundial(ranking: 36, nombre: "Escocia", probabilidadGanar: 0.001, tendencia: "subiendo"),
                CandidatoMundial(ranking: 37, nombre: "Qatar", probabilidadGanar: 0.001, tendencia: "igual"),
                CandidatoMundial(ranking: 38, nombre: "Nueva Zelanda", probabilidadGanar: 0.001, tendencia: "igual"),
                CandidatoMundial(ranking: 39, nombre: "Jordania", probabilidadGanar: 0.0005, tendencia: "subiendo"), // Debutante
                CandidatoMundial(ranking: 40, nombre: "Cabo Verde", probabilidadGanar: 0.0005, tendencia: "subiendo"), // Debutante
                //CandidatoMundial(ranking: 42, nombre: "Italia", probabilidadGanar: 0.0005, tendencia: "igual"),
                CandidatoMundial(ranking: 41, nombre: "Haití", probabilidadGanar: 0.0001, tendencia: "igual"),
                CandidatoMundial(ranking: 42, nombre: "Curazao", probabilidadGanar: 0.0001, tendencia: "subiendo"), // Debutante
                // Cupos de Repechaje (Asignando probabilidad baja por no estar definidos aún)
                CandidatoMundial(ranking: 43, nombre: "Repechaje Europa 1", probabilidadGanar: 0.0001, tendencia: "igual"),
                CandidatoMundial(ranking: 44, nombre: "Repechaje Europa 2", probabilidadGanar: 0.0001, tendencia: "igual"),
                CandidatoMundial(ranking: 45, nombre: "Repechaje Europa 3", probabilidadGanar: 0.0001, tendencia: "igual"),
                CandidatoMundial(ranking: 46, nombre: "Repechaje Europa 4", probabilidadGanar: 0.0001, tendencia: "igual"),
                CandidatoMundial(ranking: 47, nombre: "Repechaje Intercontiental 1", probabilidadGanar: 0.0001, tendencia: "igual"),
                CandidatoMundial(ranking: 48, nombre: "Repechaje Intercontiental 2", probabilidadGanar: 0.0001, tendencia: "igual")
        ]
    }
}
