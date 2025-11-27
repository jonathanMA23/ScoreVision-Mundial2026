import SwiftUI
import Charts

struct AnalisisView: View {
    // Datos simulados de "Eficiencia Goleadora" (Goles vs xG)
    struct TeamEfficiency: Identifiable {
        let id = UUID()
        let name: String
        let xG: Double
        let goals: Double
        let color: Color
    }
    
    let efficiencyData: [TeamEfficiency] = [
        TeamEfficiency(name: "Brasil", xG: 12.5, goals: 15, color: .yellow),
        TeamEfficiency(name: "Francia", xG: 10.2, goals: 11, color: .blue),
        TeamEfficiency(name: "México", xG: 4.5, goals: 6, color: .green), // Sobre-desempeño positivo
        TeamEfficiency(name: "Alemania", xG: 8.0, goals: 5, color: .white), // Bajo desempeño
        TeamEfficiency(name: "Inglaterra", xG: 9.1, goals: 9, color: .red)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25) {
                    
                    // Header
                    VStack(alignment: .leading) {
                        Text("BIG DATA MUNDIAL")
                            .font(.caption).fontWeight(.black).tracking(2).foregroundColor(.purple)
                        Text("Torneo en Cifras")
                            .font(.largeTitle).bold().foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // 1. GRÁFICA DE EFICIENCIA (Scatter Plot)
                    // Esto es único y muy "analista pro"
                    VStack(alignment: .leading) {
                        Text("EFICIENCIA GOLEADORA")
                            .font(.headline).bold()
                        Text("Goles Esperados (xG) vs Goles Reales")
                            .font(.caption).foregroundColor(.secondary)
                        
                        Chart {
                            ForEach(efficiencyData) { team in
                                PointMark(
                                    x: .value("xG", team.xG),
                                    y: .value("Goles", team.goals)
                                )
                                .foregroundStyle(team.color)
                                .symbolSize(100)
                                .annotation(position: .overlay) {
                                    Text(team.name.prefix(3)) // Abreviación (BRA, FRA)
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            // Línea de promedio (quienes estén arriba definen bien)
                            RuleMark(y: .value("Promedio", 10))
                                .foregroundStyle(.gray.opacity(0.3))
                                .lineStyle(StrokeStyle(dash: [5]))
                        }
                        .frame(height: 220)
                        .chartXAxisLabel("Generación de Juego (xG)")
                        .chartYAxisLabel("Definición (Goles)")
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)
                    
                    // 2. TARJETAS DE INSIGHTS GLOBALES
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            InsightCard(
                                title: "Muro Defensivo",
                                value: "Marruecos",
                                subtitle: "0.2 xG concedidos/partido",
                                icon: "shield.fill",
                                color: .red
                            )
                            InsightCard(
                                title: "Rey de la Posesión",
                                value: "España",
                                subtitle: "72% promedio",
                                icon: "figure.soccer",
                                color: .orange
                            )
                            InsightCard(
                                title: "Más Tarjetas",
                                value: "Uruguay",
                                subtitle: "3.5 por partido",
                                icon: "square.fill.on.square.fill",
                                color: .yellow
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // 3. RANKING DE GOLEO (Golden Boot Race)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("CARRERA BOTA DE ORO").font(.headline).bold().padding(.horizontal)
                        
                        ForEach(0..<4) { i in
                            HStack {
                                Text("\(i+1)").font(.title3).bold().foregroundColor(.secondary).frame(width: 30)
                                Circle().fill(Color.gray.opacity(0.3)).frame(width: 40, height: 40) // Foto jugador
                                VStack(alignment: .leading) {
                                    Text(["Mbappé", "Kane", "Messi", "Santi G."][i]).font(.headline)
                                    Text(["Francia", "Inglaterra", "Argentina", "México"][i]).font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(5-i) Goles").font(.headline).bold().foregroundColor(.primary)
                            }
                            .padding(.horizontal)
                            Divider().padding(.leading, 80)
                        }
                    }
                    .padding(.vertical)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
    }
}

// Componente Tarjeta Insight
struct InsightCard: View {
    let title: String, value: String, subtitle: String, icon: String, color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Spacer()
                Image(systemName: "arrow.up.right").font(.caption).foregroundColor(.secondary)
            }
            Text(value).font(.title2).bold()
            Text(title).font(.caption).fontWeight(.bold).foregroundColor(.secondary)
            Text(subtitle).font(.caption2).foregroundColor(.gray)
        }
        .padding()
        .frame(width: 160, height: 140)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.2), lineWidth: 1))
    }
}

struct AnalisisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalisisView().preferredColorScheme(.dark)
    }
}
