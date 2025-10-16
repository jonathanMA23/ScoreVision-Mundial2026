import SwiftUI
import Charts
struct EquipoView: View {
    // Inicializar el ViewModel
    @StateObject var viewModel = EquipoViewModel()
    
    var body: some View {
        NavigationView {
            List {
                // ... (Sección de Selección de Equipo, manteniéndola simple por ahora) ...

                // --- Título del Análisis ---
                Section {
                    HStack {
                        Text("\(viewModel.equipoNombre)") // Usamos el nombre del VM
                            .font(.title)
                            .bold()
                        Text("IA Rango IA: #\(viewModel.rankingIA)")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(5)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(5)
                    }
                    Text("Tendencia de Rendimiento: \(viewModel.tendenciaRendimiento)")
                        .font(.headline)
                        .foregroundColor(viewModel.tendenciaRendimiento == "Mejorando" ? .green : .orange)
                }
                .listRowSeparator(.hidden)

                // --- Gráfico de Tendencia (Simulación) ---
                // Aquí iría el gráfico real usando datosTendencia del ViewModel
                VStack(alignment: .leading) {
                    Text("Gráfico de Progreso 📈")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Chart {
                        ForEach(Array(viewModel.datosTendencia.enumerated()), id: \.offset) { index, rendimiento in
                            LineMark(
                                x: .value("Partido", index), // Índice del partido (0, 1, 2, ...)
                                y: .value("Rendimiento", rendimiento) // El valor de la tendencia
                            )
                            .interpolationMethod(.monotone) // Suaviza la línea
                            .lineStyle(StrokeStyle(lineWidth: 3))

                            PointMark(
                                x: .value("Partido", index),
                                y: .value("Rendimiento", rendimiento)
                            )
                            .opacity(0.1)
                            .annotation(position: .overlay, alignment: .top) {
                                // Muestra la tendencia al final de la gráfica
                                if index == viewModel.datosTendencia.count - 1 {
                                    Text("")
                                }
                            }
                        }
                    }
                    .chartYScale(domain: 0...100) // 👈 Rango de 0 a 100% de rendimiento
                    .chartYAxis(.hidden)
                    // Métricas clave
                    HStack {
                        VStack { Text("Goles").font(.caption); Text("G") } // Icono simulado
                        Spacer()
                        VStack { Text("Posesión Efectiva:").font(.caption); Text("\(viewModel.posesionEfectiva)%").bold() }
                        Spacer()
                        VStack { Text("Tiros").font(.caption); Text("18") } // Icono simulado
                        Spacer()
                        VStack { Text("Puerta").font(.caption); Text("\(viewModel.tirosAPuerta)").bold() } // Icono simulado
                    }
                    .padding(.top, 10)
                }
                .padding(.vertical)
                .listRowSeparator(.hidden)
                
                // --- Predicción Jugador IA (Rodrygo) ---
                Section(header: Text("Predicción Jugador IA")) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Goles Estimados (Rodrygo) \(String(format: "%.1f", viewModel.jugadorClave.golesEstimados)) +\(String(format: "%.1f", viewModel.jugadorClave.mejora))")
                            .font(.headline)
                        Text("Prob. de Gol: \(String(format: "%.0f", viewModel.jugadorClave.probabilidadGol * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Partidos Recientes")
                            .font(.caption).bold()
                            .padding(.top, 5)
                        Text(viewModel.jugadorClave.partidosRecientes)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
            .listStyle(.plain) // Usando .plain para evitar el error anterior
            .navigationTitle("Equipo")
        }
    }
}

