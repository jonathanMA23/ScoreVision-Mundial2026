import SwiftUI
import Kingfisher

struct EquipoView: View {
    @StateObject var viewModel = EquipoViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // ELIMINADO: Color de fondo fijo. Ahora usa el del sistema por defecto.
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Informativo
                    VStack(alignment: .leading, spacing: 8) {
                        Text("POWER RANKING 2026")
                            .font(.caption)
                            .fontWeight(.black)
                            .tracking(2)
                            .foregroundColor(.secondary) // Adaptativo
                        
                        Text("Probabilidad de Campeón")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary) // Adaptativo (Blanco/Negro)
                        
                        Text("Basado en simulaciones de ScoreVision AI")
                            .font(.caption)
                            .foregroundColor(.purple)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Lista de Candidatos
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.candidatos) { candidato in
                                CandidatoRow(candidato: candidato)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Subvista para cada fila
struct CandidatoRow: View {
    let candidato: CandidatoMundial
    
    // Generar URL de bandera
    var flagUrl: URL? {
        let name = candidato.nombre.replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://ui-avatars.com/api/?name=\(name)&background=random&color=fff&size=128&rounded=true&bold=true")
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // 1. Ranking
            Text("#\(candidato.ranking)")
                .font(.system(size: 16, weight: .black))
                .foregroundColor(candidato.ranking <= 3 ? .yellow : .secondary) // .secondary se adapta mejor que .gray
                .frame(width: 45, alignment: .leading)
            
            // 2. Bandera
            KFImage(flagUrl)
                .placeholder { Circle().fill(Color.gray.opacity(0.3)) }
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1)) // Borde sutil adaptativo
            
            // 3. Datos Nombre y Barra
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(candidato.nombre)
                        .font(.headline)
                        .foregroundColor(.primary) // Adaptativo
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Porcentaje texto
                    Text(String(format: "%.1f%%", candidato.probabilidadGanar * 100))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(colorPorProbabilidad(candidato.probabilidadGanar))
                }
                
                // Barra de Probabilidad
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Fondo barra (gris suave adaptativo)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 6)
                        
                        // Progreso
                        let anchoBarra = min(geometry.size.width, geometry.size.width * CGFloat(candidato.probabilidadGanar * 4.0))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [colorPorProbabilidad(candidato.probabilidadGanar), .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: anchoBarra, height: 6)
                    }
                }
                .frame(height: 6)
            }
            
            // 4. Icono Tendencia
            Image(systemName: iconoTendencia(candidato.tendencia))
                .foregroundColor(colorTendencia(candidato.tendencia))
                .font(.caption)
        }
        .padding()
        // Fondo de la tarjeta: Se adapta al sistema (gris claro en modo claro, gris oscuro en modo oscuro)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // Helpers visuales
    func colorPorProbabilidad(_ p: Double) -> Color {
        if p > 0.15 { return .green }
        if p > 0.08 { return .blue }
        return .gray
    }
    
    func iconoTendencia(_ t: String) -> String {
        switch t {
        case "subiendo": return "arrow.up.right"
        case "bajando": return "arrow.down.right"
        default: return "minus"
        }
    }
    
    func colorTendencia(_ t: String) -> Color {
        switch t {
        case "subiendo": return .green
        case "bajando": return .red
        default: return .secondary
        }
    }
}

struct EquipoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EquipoView()
                .preferredColorScheme(.dark) // Previsualización Oscura
            EquipoView()
                .preferredColorScheme(.light) // Previsualización Clara
        }
    }
}
