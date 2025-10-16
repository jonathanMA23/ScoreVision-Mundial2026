import SwiftUI
import Charts
import Combine

// MARK: - Reusable Helper Views for Details
/// A view to display a single statistic with a label.
struct StatView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

/// A view that shows a compact analysis for a single team.
struct AnalisisEquipoRowView: View {
    let equipo: Equipo
    
    // Mock data for the trend chart to simulate recent performance
    let datosTendencia: [Double] = (1...5).map { _ in Double.random(in: 10.0...10.8) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(equipo.nombre)
                    .font(.headline)
                Spacer()
                Text("Rango IA: #\(equipo.rankingIA)")
                    .font(.caption)
                    .foregroundColor(.green)
                    .bold()
            }
            
            Text("Tendencia de Rendimiento")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Chart {
                ForEach(Array(datosTendencia.enumerated()), id: \.offset) { index, rendimiento in
                    LineMark(
                        x: .value("Partido", index),
                        y: .value("Rendimiento", rendimiento)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(Color.green.gradient)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 50)
            
            // Key stats for the team (mocked for demonstration)
            HStack {
                StatView(label: "Posesión", value: "\(Int.random(in: 45...65))%")
                Spacer()
                StatView(label: "Tiros", value: "\(Int.random(in: 8...20))")
                Spacer()
                StatView(label: "A Puerta", value: "\(Int.random(in: 3...10))")
            }
        }
        .padding(.vertical, 8)
    }
}


// MARK: - Main Detail ViewModel
class PartidoDetalleViewModel: ObservableObject {
    @Published var partido: Partido
    
    /// Data for the probability chart.
    var probabilidadData: [(equipo: String, probabilidad: Double, color: Color)] {
        [
            (equipo: partido.equipoLocal.nombre, probabilidad: partido.prediccionIA.probabilidadLocal, color: .blue),
            (equipo: "Empate", probabilidad: partido.prediccionIA.probabilidadEmpate, color: .gray),
            (equipo: partido.equipoVisitante.nombre, probabilidad: partido.prediccionIA.probabilidadVisitante, color: .red)
        ]
    }
    
    /// Mock data for match-specific Expected Goals (xG).
    var xgData: [(equipo: String, xG: Double, color: Color)] {
         [
             (equipo: partido.equipoLocal.nombre, xG: Double.random(in: 0.8...2.5), color: .blue),
             (equipo: partido.equipoVisitante.nombre, xG: Double.random(in: 0.5...2.2), color: .red)
         ]
     }
    
    init(partido: Partido) {
        self.partido = partido
    }
}

// MARK: - Main Detail View
struct PartidoDetalleView: View {
    @StateObject var viewModel: PartidoDetalleViewModel
    
    init(partido: Partido) {
        _viewModel = StateObject(wrappedValue: PartidoDetalleViewModel(partido: partido))
    }
    
    var body: some View {
        List {
            // MARK: - Header Section
            Section {
                VStack {
                    HStack {
                        VStack {
                            Text(viewModel.partido.equipoLocal.nombre).font(.headline)
                            Text("Local").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        if let marcadorLocal = viewModel.partido.marcadorLocal, let marcadorVisitante = viewModel.partido.marcadorVisitante {
                            Text("\(marcadorLocal) - \(marcadorVisitante)")
                                .font(.system(size: 40, weight: .bold))
                        } else {
                            Text("VS").font(.system(size: 30, weight: .light))
                        }
                        Spacer()
                        VStack {
                            Text(viewModel.partido.equipoVisitante.nombre).font(.headline)
                            Text("Visitante").font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical)
                    
                    HStack {
                        Text(viewModel.partido.estadio)
                        Spacer()
                        Text(viewModel.partido.estado.rawValue)
                            .foregroundColor(viewModel.partido.estado == .enVivo ? .red : .secondary)
                            .bold()
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            
            // MARK: - IA Prediction Section
            Section(header: Text("Análisis Predictivo (IA)")) {
                VStack(alignment: .leading) {
                    Text("Probabilidades de Resultado").font(.headline).padding(.bottom, 5)
                    Chart(viewModel.probabilidadData, id: \.equipo) { item in
                        BarMark(x: .value("Probabilidad", item.probabilidad * 100))
                            .foregroundStyle(item.color)
                    }
                    .chartXAxis(.hidden)
                    .frame(height: 100)
                }
                .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Resultado Más Probable (IA):")
                    Text(viewModel.partido.prediccionIA.posibleResultado)
                        .font(.title2.weight(.semibold))
                }
            }
            
            // MARK: - Match Key Metrics Section
            Section(header: Text("Métricas Clave del Partido")) {
                ForEach(viewModel.xgData, id: \.equipo) { data in
                    HStack {
                        Text("Goles Esperados (\(data.equipo))")
                        Spacer()
                        Text("\(String(format: "%.1f", data.xG)) xG")
                            .bold()
                            .foregroundColor(data.color)
                    }
                }
            }
            
            // MARK: - Team Analysis Section
            Section(header: Text("Análisis de Equipos")) {
                AnalisisEquipoRowView(equipo: viewModel.partido.equipoLocal)
                AnalisisEquipoRowView(equipo: viewModel.partido.equipoVisitante)
            }
            
            // MARK: - Top Goalscorers Section
            if !viewModel.partido.prediccionIA.topGoleadoresEstimados.isEmpty {
                Section(header: Text("Goleadores Clave del Partido")) {
                    ForEach(viewModel.partido.prediccionIA.topGoleadoresEstimados) { jugador in
                        HStack {
                            Text(jugador.nombre)
                            Spacer()
                            Text("Prob. Gol: \(String(format: "%.0f", jugador.probabilidadGol * 100))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Detalle del Partido")
        .navigationBarTitleDisplayMode(.inline)
    }
}


