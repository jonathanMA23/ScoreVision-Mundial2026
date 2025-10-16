import SwiftUI


// --- VISTA PRINCIPAL MEJORADA ---
struct PartidosView: View {
    
    @StateObject var viewModel = PartidosViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // --- Selector de Filtro ---
                Picker("Filtro", selection: $viewModel.filtroSeleccionado.animation(.easeInOut)) {
                    ForEach(PartidosFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])
                .padding(.bottom, 8)

                // --- Lista de Partidos ---
                List {
                    // --- Sección especial para partido EN VIVO ---
                    if let livePartido = viewModel.partidoEnVivo, viewModel.filtroSeleccionado == .hoy {
                        Section {
                            // Usamos el nuevo diseño de tarjeta
                            PartidoCardView(partido: livePartido)
                        } header: {
                            HStack(spacing: 4) {
                                Image(systemName: "record.circle.fill")
                                Text("En Vivo")
                            }
                            .font(.headline).foregroundColor(.red)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    
                    // --- Partidos Filtrados ---
                    Section {
                        if viewModel.partidosFiltrados.filter({ $0.estado != .enVivo }).isEmpty {
                            Text("No hay partidos para mostrar en esta categoría.")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(viewModel.partidosFiltrados.filter { $0.estado != .enVivo }) { partido in
                                NavigationLink(destination: Text("Detalle para \(partido.equipoLocal.nombre)")) {
                                    PartidoCardView(partido: partido)
                                }
                            }
                        }
                    } header: {
                        // Header dinámico
                        Text(viewModel.filtroSeleccionado == .hoy ? "Próximos de Hoy" : viewModel.filtroSeleccionado.rawValue)
                            .font(.headline)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    
                    // --- Sección de Goleadores ---
                    if viewModel.filtroSeleccionado == .hoy && !viewModel.topGoleadores.isEmpty {
                        Section(header: Text("Top 5 Goleadores del Día (IA)").font(.headline)) {
                            ForEach(Array(viewModel.topGoleadores.enumerated()), id: \.element.id) { index, jugador in
                                // Usamos la nueva fila de goleador
                                GoleadorRowView(jugador: jugador, rank: index + 1)
                            }
                        }
                    }
                }
                .listStyle(.plain) // Estilo plain para dar control total a las tarjetas
                .refreshable {
                    await viewModel.cargarPartidos()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Partidos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ScoreVision AI").bold()
                }
            }
        }
    }
}


// --- COMPONENTES REUTILIZABLES REDISEÑADOS ---

// --- Tarjeta de Partido ---
struct PartidoCardView: View {
    let partido: Partido

    var body: some View {
        VStack(spacing: 12) {
            // Fila de equipos y marcador
            HStack {
                // Equipo Local
                HStack(spacing: 12) {
                    // Asume que tienes una función o asset para las banderas
                    Image(partido.equipoLocal.nombre.lowercased())
                        .resizable().aspectRatio(contentMode: .fit).frame(width: 35, height: 25)
                        .clipShape(RoundedRectangle(cornerRadius: 4)).shadow(radius: 1)
                    Text(partido.equipoLocal.nombre).font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Marcador o Fecha
                VStack {
                    if let marcadorLocal = partido.marcadorLocal, let marcadorVisitante = partido.marcadorVisitante {
                        Text("\(marcadorLocal) - \(marcadorVisitante)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                    } else {
                        Text(partido.fecha.contains("Oct") ? "Próximo" : partido.fecha) // Muestra la hora si es de hoy
                            .font(.subheadline.bold()).padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15)).clipShape(Capsule())
                    }
                }
                
                // Equipo Visitante
                HStack(spacing: 12) {
                    Text(partido.equipoVisitante.nombre).font(.headline)
                    Image(partido.equipoVisitante.nombre.lowercased())
                        .resizable().aspectRatio(contentMode: .fit).frame(width: 35, height: 25)
                        .clipShape(RoundedRectangle(cornerRadius: 4)).shadow(radius: 1)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            // Fila de metadata
            if partido.estado != .proximo { Divider().padding(.horizontal) }
            HStack {
                if partido.estado == .enVivo { LiveBadge(minuto: partido.fecha) }
                else { Text(partido.estado.rawValue).font(.caption.bold()).foregroundColor(.secondary) }
                Spacer()
                HStack(spacing: 4) {
                    if !partido.prediccionIA.topGoleadoresEstimados.isEmpty { Image(systemName: "star.fill").foregroundColor(.yellow) }
                    Text(partido.estadio)
                }.font(.caption).foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial) // Efecto de cristal esmerilado
        .cornerRadius(16)
        .overlay(
            partido.estado == .enVivo ?
                RoundedRectangle(cornerRadius: 16).stroke(Color.red, lineWidth: 1.5) : nil
        )
    }
}

// --- Fila de Goleador ---
struct GoleadorRowView: View {
    let jugador: EstimacionJugador
    let rank: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)").font(.caption.bold()).foregroundColor(.secondary).frame(width: 20)
            Image(systemName: "person.fill").font(.title3).padding(10)
                .background(Color.gray.opacity(0.2)).clipShape(Circle())
            Text(jugador.nombre).fontWeight(.medium)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("xG: \(String(format: "%.1f", jugador.golesEstimados))").font(.headline.monospacedDigit())
                Text("Prob: \(String(format: "%.0f%%", jugador.probabilidadGol * 100))").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

// --- Insignia "En Vivo" Animada ---
struct LiveBadge: View {
    let minuto: String
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(Color.red).frame(width: 8, height: 8)
                .scaleEffect(isAnimating ? 1.2 : 1).opacity(isAnimating ? 0.5 : 1)
                .onAppear { withAnimation(.easeInOut(duration: 0.8).repeatForever()) { isAnimating = true } }
            Text("\(minuto) | EN VIVO").font(.caption.bold()).foregroundColor(.red)
        }
    }
}

// --- Previsualización ---
struct PartidosView_Previews: PreviewProvider {
    static var previews: some View {
        PartidosView()
            .preferredColorScheme(.dark)
    }
}
