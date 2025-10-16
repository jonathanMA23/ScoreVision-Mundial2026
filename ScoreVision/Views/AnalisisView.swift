import SwiftUI




// --- Vista Principal Mejorada ---
struct AnalisisView: View {
    @StateObject var viewModel = AnalisisViewModel()

    var body: some View {
        NavigationView {
            List {
                // --- Sección 1: Visión General ---
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "chart.pie.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                            Text("Visión Centralizada del Mundial 2026")
                                .font(.headline)
                        }
                        Text("ScoreVision AI: Análisis en tiempo real de 120+ métricas por partido.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                // --- Sección 2: Métrica de Posesión Efectiva ---
                Section(header: Text("Métrica Clave").font(.headline).padding(.leading, -1)) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "figure.soccer")
                            Text("Posesión Efectiva Promedio")
                        }
                        .font(.headline)

                        HStack {
                            Text("\(viewModel.posesionEfectiva)%")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Factor Clave")
                                    .font(.caption.bold())
                                    .foregroundColor(.orange)
                                Text("Pases progresivos y tiros a puerta.")
                                    .font(.caption)
                                    .multilineTextAlignment(.trailing)
                            }
                        }

                        // Barra de progreso para comparación visual
                        VStack(alignment: .leading) {
                            ProgressView(value: Double(viewModel.posesionEfectiva), total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                            Text("Promedio del torneo: \(viewModel.promedioTorneo)%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical)
                }

                // --- Sección 3: Goles Esperados (xG) ---
                Section(header: Text("Goles Esperados (xG)").font(.headline).padding(.leading, -1)) {
                    ForEach(viewModel.xGData) { data in
                        HStack(spacing: 16) {
                            Image(systemName: "soccerball.inverse")
                                .font(.title2)
                                .foregroundColor(data.color)
                            
                            VStack(alignment: .leading) {
                                Text(data.equipo)
                                    .font(.headline)
                                Text("Probabilidad de gol por jugada")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(String(format: "%.1f xG", data.xG))
                                .font(.title2.bold())
                                .foregroundColor(data.color)
                        }
                        .padding(.vertical, 8)
                    }
                }

                // --- Sección 4: Hallazgos de la IA ---
                Section(header: Text("Hallazgos de la IA").font(.headline).padding(.leading, -1)) {
                    HStack(alignment: .top) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                            .padding(.top, 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.hallazgoTendencia)
                                .font(.headline)
                                .foregroundColor(.red)
                            Text(viewModel.justificacionTendencia)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .listStyle(.insetGrouped) // Cambio clave para un look moderno
            .navigationTitle("Análisis ScoreVision")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// --- Vista de Previsualización ---
struct AnalisisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalisisView()
            .preferredColorScheme(.dark) // Vista previa en modo oscuro
    }
}
