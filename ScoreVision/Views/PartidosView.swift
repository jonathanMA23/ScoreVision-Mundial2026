import SwiftUI
import Kingfisher
import Combine

// MARK: - Vista Principal de Partidos
struct PartidosView: View {
    @StateObject var viewModel = PartidosViewModel()
    @State private var filtroSeleccionado = "Hoy" // Estado para el filtro
    let categorias = ["Hoy", "Próximos", "Terminados"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo Oscuro Global
                Color(red: 2/255, green: 6/255, blue: 23/255).ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 25) {
                        
                        // --- Header ---
                        HStack {
                            VStack(alignment: .leading) {
                                Text("MUNDIAL 2026")
                                    .font(.caption).fontWeight(.black).tracking(2).foregroundColor(.purple)
                                Text("Partidos")
                                    .font(.largeTitle).fontWeight(.bold).foregroundColor(.white)
                            }
                            Spacer()
                            // Avatar de usuario
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 40, height: 40)
                                .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // --- Filtros de Categoría (Estilo Cápsula) ---
                        HStack(spacing: 12) {
                            ForEach(categorias, id: \.self) { categoria in
                                Button(action: {
                                    withAnimation { filtroSeleccionado = categoria }
                                }) {
                                    Text(categoria)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(filtroSeleccionado == categoria ? .black : .white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 24)
                                        .background(
                                            filtroSeleccionado == categoria ? Color.green : Color.white.opacity(0.1)
                                        )
                                        .clipShape(Capsule())
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // --- LÓGICA DE VISUALIZACIÓN ---
                        
                        // 1. Sección HOY (Incluye Destacado + Lista)
                        if filtroSeleccionado == "Hoy" {
                            // Identificamos el partido destacado (En Vivo) para no repetirlo
                            let destacado = viewModel.partidos.first(where: { $0.estado == .enVivo })
                            
                            // Mostrar Tarjeta Destacada si existe
                            if let vivo = destacado {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Circle().fill(Color.red).frame(width: 8, height: 8)
                                            .shadow(color: .red, radius: 5)
                                        Text("PARTIDO DESTACADO").font(.caption).bold().foregroundColor(.white)
                                    }
                                    .padding(.horizontal)
                                    
                                    NavigationLink(destination: DetallePartidoView(partido: vivo)) {
                                        FeaturedMatchCard(partido: vivo)
                                    }
                                }
                            }
                            
                            // Lista de Hoy
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Calendario").font(.headline).foregroundColor(.gray).padding(.horizontal)
                                
                                // Filtramos los partidos de hoy y EXCLUIMOS el destacado comparando IDs (UUIDs)
                                let partidosHoy = viewModel.partidos.filter { partido in
                                    let esDeHoy = (partido.estado == .enVivo || partido.fecha == "12 Jun")
                                    // Si hay destacado, filtramos para no mostrar el mismo ID. Si no hay, mostramos todo.
                                    let noEsDestacado = partido.id != destacado?.id
                                    return esDeHoy && noEsDestacado
                                }
                                
                                if partidosHoy.isEmpty {
                                    EmptyStateView(mensaje: "No hay más partidos hoy")
                                } else {
                                    ForEach(partidosHoy) { partido in
                                        NavigationLink(destination: DetallePartidoView(partido: partido)) {
                                            MatchRowCard(partido: partido)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 2. Sección PRÓXIMOS
                        else if filtroSeleccionado == "Próximos" {
                            VStack(alignment: .leading, spacing: 15) {
                                let proximos = viewModel.partidos.filter { $0.estado == .proximo }
                                
                                if proximos.isEmpty {
                                    EmptyStateView(mensaje: "No hay partidos próximos programados")
                                } else {
                                    ForEach(proximos) { partido in
                                        NavigationLink(destination: DetallePartidoView(partido: partido)) {
                                            MatchRowCard(partido: partido)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 3. Sección TERMINADOS
                        else if filtroSeleccionado == "Terminados" {
                            VStack(alignment: .leading, spacing: 15) {
                                let terminados = viewModel.partidos.filter { $0.estado == .finalizado }
                                
                                if terminados.isEmpty {
                                    EmptyStateView(mensaje: "Aún no hay partidos finalizados")
                                } else {
                                    ForEach(terminados) { partido in
                                        NavigationLink(destination: DetallePartidoView(partido: partido)) {
                                            MatchRowCard(partido: partido)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Spacer().frame(height: 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// --- Vista para estados vacíos ---
struct EmptyStateView: View {
    let mensaje: String
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "sportscourt")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.3))
            Text(mensaje)
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}

// MARK: - Componentes Visuales (Tarjetas)

struct FeaturedMatchCard: View {
    let partido: Partido
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                // Local
                VStack {
                    BanderaView(nombre: partido.equipoLocal.nombre, size: 60)
                    Text(partido.equipoLocal.codigoFIFA).font(.headline).bold().foregroundColor(.white)
                }
                Spacer()
                // Marcador Central
                VStack {
                    if let loc = partido.marcadorLocal, let vis = partido.marcadorVisitante {
                        Text("\(loc) - \(vis)")
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(.white)
                    } else {
                        Text("VS")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    Text(partido.fecha)
                        .font(.caption).bold().foregroundColor(.green)
                }
                Spacer()
                // Visitante
                VStack {
                    BanderaView(nombre: partido.equipoVisitante.nombre, size: 60)
                    Text(partido.equipoVisitante.codigoFIFA).font(.headline).bold().foregroundColor(.white)
                }
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            HStack {
                Image(systemName: "mappin.and.ellipse").foregroundColor(.gray)
                Text(partido.estadio).font(.caption).foregroundColor(.gray)
                Spacer()
                Text("Ver Detalles").font(.caption).bold().foregroundColor(.purple)
                Image(systemName: "arrow.right").font(.caption).foregroundColor(.purple)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .padding(.horizontal)
    }
}

struct MatchRowCard: View {
    let partido: Partido
    
    var body: some View {
        HStack(spacing: 15) {
            // Fecha / Estado Izquierda
            VStack {
                Text(partido.fecha)
                    .font(.caption).bold()
                    .foregroundColor(partido.estado == .finalizado ? .gray : .white)
                    .multilineTextAlignment(.center)
                
                if partido.estado == .finalizado {
                    Text("FT").font(.caption2).foregroundColor(.gray)
                }
            }
            .frame(width: 50)
            
            // Equipos y Marcador
            VStack(spacing: 8) {
                // Equipo Local
                HStack {
                    BanderaView(nombre: partido.equipoLocal.nombre, size: 24)
                    Text(partido.equipoLocal.nombre).font(.subheadline).fontWeight(.medium).foregroundColor(.white)
                    Spacer()
                    if let score = partido.marcadorLocal {
                        Text("\(score)").font(.subheadline).bold().foregroundColor(.white)
                    } else {
                        Text("-").font(.subheadline).foregroundColor(.gray)
                    }
                }
                // Equipo Visitante
                HStack {
                    BanderaView(nombre: partido.equipoVisitante.nombre, size: 24)
                    Text(partido.equipoVisitante.nombre).font(.subheadline).fontWeight(.medium).foregroundColor(.white)
                    Spacer()
                    if let score = partido.marcadorVisitante {
                        Text("\(score)").font(.subheadline).bold().foregroundColor(.white)
                    } else {
                        Text("-").font(.subheadline).foregroundColor(.gray)
                    }
                }
            }
            
            Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct BanderaView: View {
    let nombre: String
    let size: CGFloat
    var url: URL? { URL(string: "https://ui-avatars.com/api/?name=\(nombre.replacingOccurrences(of: " ", with: "+"))&background=random&color=fff&size=128&rounded=true&bold=true") }
    
    var body: some View {
        KFImage(url)
            .placeholder { Circle().fill(Color.gray) }
            .resizable()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}



struct PartidosView_Previews: PreviewProvider {
    static var previews: some View {
        PartidosView().preferredColorScheme(.dark)
    }
}
