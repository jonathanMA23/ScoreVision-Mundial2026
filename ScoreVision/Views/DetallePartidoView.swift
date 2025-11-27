import SwiftUI
import Charts
import Lottie
import Kingfisher

struct DetallePartidoView: View {
    let partido: Partido
    
    @Environment(\.presentationMode) var presentationMode
    @State private var tabSeleccionada = "Resumen"
    @Namespace private var animation
    @State private var mostrarCelebracion = false
    
    // --- LÓGICA DINÁMICA: Generar gráficos basados en el JSON del partido ---
    
    // 1. Momentum: Basado en la probabilidad de victoria
    // Si probabilidadLocal es alta, la gráfica se inclina hacia arriba (verde).
    var momentumData: [MatchMomentumPoint] {
        let bias = (partido.prediccionIA.probabilidadLocal - 0.5) * 100 // Sesgo hacia local o visita
        
        // Usamos el ID del partido para que la "aleatoriedad" sea consistente siempre para el mismo partido
        var generator = SeededGenerator(seed: UInt64(partido.id.hashValue))
        
        return (0..<15).map { i in
            // Base aleatoria + el sesgo de la IA
            let randomValue = Double.random(in: -30...30, using: &generator)
            let trend = bias * (Double(i) / 15.0) // El dominio suele aumentar con el tiempo
            return MatchMomentumPoint(minute: i * 6, strength: randomValue + trend)
        }
    }
    
    // 2. Estadísticas: Derivadas de la probabilidad IA
    var statsComparison: [MatchStatComparison] {
        let probLocal = partido.prediccionIA.probabilidadLocal
        
        // Simulación inteligente basada en quién es favorito
        let xGLocal = 1.2 + (probLocal * 1.5) // Entre 1.2 y 2.7
        let xGVisitante = 1.2 + (partido.prediccionIA.probabilidadVisitante * 1.5)
        
        let posesionLocal = 35.0 + (probLocal * 30.0) // Entre 35% y 65% base + varianza
        let posesionVisitante = 100.0 - posesionLocal
        
        let pasesLocal = posesionLocal * 5.5 // Aprox 5.5 pases por % de posesión
        let pasesVisitante = posesionVisitante * 5.5
        
        return [
            MatchStatComparison(metric: "Goles Esp. (xG)", localValue: xGLocal, visitValue: xGVisitante, maxScale: 3.5),
            MatchStatComparison(metric: "Posesión %", localValue: posesionLocal, visitValue: posesionVisitante, maxScale: 100),
            MatchStatComparison(metric: "Pases", localValue: pasesLocal, visitValue: pasesVisitante, maxScale: 600)
        ]
    }
    
    var body: some View {
        ZStack {
            Color(red: 2/255, green: 6/255, blue: 23/255).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navegación
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text(partido.estadio.uppercased())
                        .font(.caption).fontWeight(.black).tracking(2).foregroundColor(.gray)
                    Spacer()
                    Button(action: { withAnimation { mostrarCelebracion.toggle() } }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal).padding(.top, 10)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        MarcadorDinamicoView(partido: partido)
                        
                        // Tabs
                        TabsView(seleccion: $tabSeleccionada, animation: animation)
                        
                        // --- CONTENIDO DINÁMICO DE PESTAÑAS ---
                        if tabSeleccionada == "Resumen" {
                            ResumenDinamicoView() // Timeline Vertical
                        }
                        else if tabSeleccionada == "Alineación" {
                            AlineacionView() // Cancha de Fútbol
                        }
                        else if tabSeleccionada == "Estadísticas" {
                            // Pasamos los datos calculados dinámicamente
                            StatsAvanzadasView(momentumData: momentumData, stats: statsComparison)
                        }
                        else if tabSeleccionada == "IA Vision" {
                            IAVisionView(prediccion: partido.prediccionIA)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            
            // Botón Flotante (Solo si no estamos en IA Vision)
            if tabSeleccionada != "IA Vision" {
                VStack {
                    Spacer()
                    Button(action: { withAnimation { tabSeleccionada = "IA Vision" } }) {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("Ver Análisis IA ScoreVision").fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity).padding()
                        .background(LinearGradient(colors: [Color.purple, Color.blue], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white).cornerRadius(16)
                        .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal).padding(.bottom, 20)
                }
            }
            
            if mostrarCelebracion {
                LottieView(filename: "confetti", loopMode: .playOnce)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { mostrarCelebracion = false }
                    }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - GENERADOR DE ALEATORIEDAD CONSISTENTE
// Esto permite que los gráficos sean "aleatorios" pero siempre iguales para el mismo partido
struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1442695040888963407
        return state
    }
}

// MARK: - 1. RESUMEN: LÍNEA DE TIEMPO (Timeline)
struct ResumenDinamicoView: View {
    // Datos simulados de eventos para la timeline
    struct EventoPartido: Identifiable {
        let id = UUID()
        let minuto: Int
        let tipo: TipoEvento
        let jugador: String
        let descripcion: String? // Para cambios (entra/sale)
        let esLocal: Bool // True = Izquierda, False = Derecha
        
        enum TipoEvento { case gol, tarjetaAmarilla, tarjetaRoja, cambio, medioTiempo, inicio }
    }
    
    let eventos: [EventoPartido] = [
        EventoPartido(minuto: 90, tipo: .tarjetaAmarilla, jugador: "E. Álvarez", descripcion: nil, esLocal: true),
        EventoPartido(minuto: 82, tipo: .cambio, jugador: "R. Jiménez", descripcion: "Entra por H. Martin", esLocal: true),
        EventoPartido(minuto: 75, tipo: .gol, jugador: "L. Sané", descripcion: nil, esLocal: false),
        EventoPartido(minuto: 68, tipo: .tarjetaRoja, jugador: "A. Rüdiger", descripcion: nil, esLocal: false),
        EventoPartido(minuto: 51, tipo: .gol, jugador: "H. Lozano", descripcion: nil, esLocal: true),
        EventoPartido(minuto: 45, tipo: .medioTiempo, jugador: "", descripcion: "HT 1-0", esLocal: true),
        EventoPartido(minuto: 23, tipo: .gol, jugador: "S. Giménez", descripcion: nil, esLocal: true),
        EventoPartido(minuto: 0, tipo: .inicio, jugador: "", descripcion: "Inicio del Partido", esLocal: true)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(eventos) { evento in
                HStack(alignment: .top, spacing: 0) {
                    // LADO IZQUIERDO (LOCAL)
                    if evento.esLocal && evento.tipo != .medioTiempo && evento.tipo != .inicio {
                        EventoCard(evento: evento, alignRight: true)
                    } else {
                        Spacer()
                    }
                    
                    // LÍNEA CENTRAL
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2)
                        
                        Circle()
                            .fill(colorParaEvento(evento.tipo))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text(evento.tipo == .medioTiempo || evento.tipo == .inicio ? "" : "\(evento.minuto)'")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                            )
                            .overlay(
                                Circle().stroke(Color.black, lineWidth: 2)
                            )
                        
                        if evento.tipo == .medioTiempo || evento.tipo == .inicio {
                            Image(systemName: evento.tipo == .medioTiempo ? "clock" : "whistle")
                                .font(.caption2)
                                .foregroundColor(.black)
                        }
                    }
                    .frame(width: 40)
                    .padding(.bottom, 20) // Espacio entre eventos
                    
                    // LADO DERECHO (VISITANTE)
                    if !evento.esLocal && evento.tipo != .medioTiempo && evento.tipo != .inicio {
                        EventoCard(evento: evento, alignRight: false)
                    } else {
                        Spacer()
                    }
                }
                
                // Bloques especiales centrales (HT, Inicio)
                if evento.tipo == .medioTiempo || evento.tipo == .inicio {
                    Text(evento.descripcion ?? "")
                        .font(.caption).bold()
                        .padding(.vertical, 4).padding(.horizontal, 12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.gray)
                        .offset(y: -10) // Subir un poco para pegar al icono
                        .padding(.bottom, 20)
                }
            }
        }
        .padding(.horizontal)
    }
    
    func colorParaEvento(_ tipo: EventoPartido.TipoEvento) -> Color {
        switch tipo {
        case .gol: return .green
        case .tarjetaAmarilla: return .yellow
        case .tarjetaRoja: return .red
        case .cambio: return .blue
        default: return .white
        }
    }
}

struct EventoCard: View {
    let evento: ResumenDinamicoView.EventoPartido
    let alignRight: Bool
    
    var body: some View {
        HStack {
            if alignRight { Spacer() }
            
            VStack(alignment: alignRight ? .trailing : .leading, spacing: 4) {
                HStack {
                    if alignRight {
                        Text(evento.jugador).font(.subheadline).bold().foregroundColor(.white)
                        iconoEvento
                    } else {
                        iconoEvento
                        Text(evento.jugador).font(.subheadline).bold().foregroundColor(.white)
                    }
                }
                
                if let desc = evento.descripcion {
                    Text(desc).font(.caption2).foregroundColor(.gray)
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            if !alignRight { Spacer() }
        }
    }
    
    var iconoEvento: some View {
        Group {
            switch evento.tipo {
            case .gol: Image(systemName: "soccerball").foregroundColor(.green)
            case .tarjetaAmarilla: Rectangle().fill(Color.yellow).frame(width: 10, height: 14).cornerRadius(2)
            case .tarjetaRoja: Rectangle().fill(Color.red).frame(width: 10, height: 14).cornerRadius(2)
            case .cambio: Image(systemName: "arrow.triangle.2.circlepath").foregroundColor(.blue)
            default: EmptyView()
            }
        }
    }
}

// MARK: - 2. ALINEACIÓN: CANCHA DE FÚTBOL
struct AlineacionView: View {
    @State private var equipoSeleccionado = 0 // 0: Local, 1: Visitante
    
    // Datos simulados de jugadores
    struct JugadorCancha: Identifiable {
        let id = UUID()
        let nombre: String
        let numero: Int
        let x: CGFloat // 0 a 1 (posición horizontal relativa)
        let y: CGFloat // 0 a 1 (posición vertical relativa)
    }
    
    // 4-3-3 para Local
    let alineacionLocal = [
        JugadorCancha(nombre: "Ochoa", numero: 13, x: 0.5, y: 0.9),
        JugadorCancha(nombre: "Sánchez", numero: 3, x: 0.2, y: 0.75),
        JugadorCancha(nombre: "Montes", numero: 19, x: 0.4, y: 0.8),
        JugadorCancha(nombre: "Vásquez", numero: 5, x: 0.6, y: 0.8),
        JugadorCancha(nombre: "Gallardo", numero: 23, x: 0.8, y: 0.75),
        JugadorCancha(nombre: "Álvarez", numero: 4, x: 0.5, y: 0.6),
        JugadorCancha(nombre: "Chávez", numero: 18, x: 0.3, y: 0.5),
        JugadorCancha(nombre: "Romo", numero: 7, x: 0.7, y: 0.5),
        JugadorCancha(nombre: "Antuna", numero: 15, x: 0.2, y: 0.25),
        JugadorCancha(nombre: "Giménez", numero: 9, x: 0.5, y: 0.2),
        JugadorCancha(nombre: "Lozano", numero: 22, x: 0.8, y: 0.25)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Selector de Equipo
            Picker("Equipo", selection: $equipoSeleccionado) {
                Text("México").tag(0)
                Text("Alemania").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Cancha
            ZStack {
                // Fondo Cancha
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        // Líneas de cancha simples
                        ZStack {
                            Rectangle().stroke(Color.white.opacity(0.3), lineWidth: 2)
                            Circle().stroke(Color.white.opacity(0.3), lineWidth: 2).frame(width: 100)
                            Rectangle().fill(Color.white.opacity(0.3)).frame(height: 2) // Medio campo
                        }
                        .padding(20)
                    )
                    .frame(height: 500)
                    .padding(.horizontal)
                
                // Jugadores
                GeometryReader { geo in
                    let w = geo.size.width - 32 // ajuste por padding
                    let h = 500.0
                    let offsetX: CGFloat = 16
                    
                    ForEach(alineacionLocal) { jugador in
                        VStack(spacing: 2) {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 30, height: 30)
                                    .shadow(radius: 3)
                                Text("\(jugador.numero)")
                                    .font(.caption).bold().foregroundColor(.black)
                            }
                            Text(jugador.nombre)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2)
                        }
                        .position(
                            x: offsetX + (jugador.x * w),
                            // Si es visitante, invertimos la Y o usamos otra alineación
                            y: equipoSeleccionado == 0 ? (jugador.y * h) : ((1 - jugador.y) * h)
                        )
                    }
                }
                .frame(height: 500)
            }
            
            // Info DT
            HStack {
                VStack(alignment: .leading) {
                    Text("Director Técnico").font(.caption).foregroundColor(.gray)
                    Text(equipoSeleccionado == 0 ? "Jaime Lozano" : "Hansi Flick").font(.headline).foregroundColor(.white)
                }
                Spacer()
                Text(equipoSeleccionado == 0 ? "4-3-3" : "4-2-3-1").font(.title3).bold().foregroundColor(.green)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

// --- SUBVISTAS DE ESTADÍSTICAS Y OTROS ---

struct StatsAvanzadasView: View {
    // Cambio: Tipos actualizados a MatchMomentumPoint y MatchStatComparison
    let momentumData: [MatchMomentumPoint]
    let stats: [MatchStatComparison]
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. Momentum Chart
            VStack(alignment: .leading) {
                Text("MOMENTUM DE JUEGO").font(.caption).bold().foregroundColor(.secondary).padding(.bottom, 8)
                
                Chart(momentumData) { point in
                    AreaMark(
                        x: .value("Minuto", point.minute),
                        y: .value("Dominio", point.strength > 0 ? point.strength : 0)
                    )
                    .foregroundStyle(LinearGradient(colors: [.green.opacity(0.6), .green.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Minuto", point.minute),
                        y: .value("Dominio", point.strength < 0 ? point.strength : 0)
                    )
                    .foregroundStyle(LinearGradient(colors: [.blue.opacity(0.1), .blue.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 150)
                .chartXAxis { AxisMarks(values: .stride(by: 15)) { AxisValueLabel(format: Decimal.FormatStyle.number) } }
                .chartYAxis(.hidden)
                
                HStack {
                    Text("Visitante").font(.caption).foregroundColor(.blue)
                    Spacer()
                    Text("Local").font(.caption).foregroundColor(.green)
                }
            }
            .padding().background(Color.white.opacity(0.05)).cornerRadius(16).padding(.horizontal)
            
            // 2. Comparativa
            VStack(alignment: .leading, spacing: 16) {
                Text("COMPARATIVA CLAVE").font(.caption).bold().foregroundColor(.secondary)
                ForEach(stats) { stat in
                    VStack(spacing: 6) {
                        HStack {
                            Text(String(format: "%.1f", stat.localValue)).font(.caption).bold().foregroundColor(.green)
                            Spacer()
                            Text(stat.metric.uppercased()).font(.caption2).fontWeight(.heavy).foregroundColor(.gray)
                            Spacer()
                            Text(String(format: "%.1f", stat.visitValue)).font(.caption).bold().foregroundColor(.blue)
                        }
                        GeometryReader { geo in
                            HStack(spacing: 4) {
                                ZStack(alignment: .trailing) {
                                    Capsule().fill(Color.gray.opacity(0.1))
                                    Capsule().fill(Color.green).frame(width: (stat.localValue / stat.maxScale) * (geo.size.width / 2))
                                }
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.gray.opacity(0.1))
                                    Capsule().fill(Color.blue).frame(width: (stat.visitValue / stat.maxScale) * (geo.size.width / 2))
                                }
                            }
                        }.frame(height: 8)
                    }
                }
            }
            .padding().background(Color.white.opacity(0.05)).cornerRadius(16).padding(.horizontal)
            
            // Espacio final
            Color.clear.frame(height: 60)
        }
    }
}

struct IAVisionView: View {
    let prediccion: PrediccionIA
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. Tarjeta de Predicción Principal
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.purple)
                    Text("PREDICCIÓN SCOREVISION")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Text("Resultado probable: \(prediccion.posibleResultado)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Barras de Probabilidad
                VStack(spacing: 16) {
                    // Local
                    ProbabilidadRow(label: "Local", valor: prediccion.probabilidadLocal, color: .green)
                    // Empate
                    ProbabilidadRow(label: "Empate", valor: prediccion.probabilidadEmpate, color: .gray)
                    // Visitante
                    ProbabilidadRow(label: "Visitante", valor: prediccion.probabilidadVisitante, color: .blue)
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
            
            // 2. Sección de Factores Clave (Restaurada)
            VStack(alignment: .leading, spacing: 10) {
                Text("Factores Clave")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                ForEach(prediccion.factoresClave, id: \.self) { factor in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        Text(factor)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            
            // Espacio final
            Color.clear.frame(height: 60)
        }
    }
}

// --- MODELOS AUXILIARES PARA GRÁFICOS (Renombrados) ---
// Se renombraron para evitar conflictos con AnalisisViewModel
struct MatchMomentumPoint: Identifiable {
    let id = UUID()
    let minute: Int
    let strength: Double
}

struct MatchStatComparison: Identifiable {
    let id = UUID()
    let metric: String
    let localValue: Double
    let visitValue: Double
    let maxScale: Double
}

// --- ACTUALIZACIÓN DE TABSVIEW ---
struct TabsView: View {
    @Binding var seleccion: String
    var animation: Namespace.ID
    
    let tabs = ["Resumen", "Alineación", "Estadísticas", "IA Vision"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                VStack {
                    Text(tab)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(seleccion == tab ? .white : .gray)
                        .padding(.bottom, 8)
                    
                    if seleccion == tab {
                        Rectangle().fill(tab == "IA Vision" ? Color.purple : Color.green)
                            .frame(height: 3).cornerRadius(1.5)
                            .matchedGeometryEffect(id: "tabIndicator", in: animation)
                    } else {
                        Rectangle().fill(Color.clear).frame(height: 3)
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { withAnimation { seleccion = tab } }
            }
        }
        .padding(.horizontal)
        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.2)), alignment: .bottom)
    }
}

// --- SUBVISTAS AUXILIARES ---

struct MarcadorDinamicoView: View {
    let partido: Partido
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                if partido.estado == .enVivo {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("EN VIVO • \(partido.fecha)").font(.caption).fontWeight(.bold).foregroundColor(.green)
                } else {
                    Text(partido.estado.rawValue.uppercased()).font(.caption).fontWeight(.bold).foregroundColor(.gray)
                }
            }
            .padding(.bottom, 20)
            
            HStack(alignment: .center) {
                EquipoColumn(nombre: partido.equipoLocal.nombre)
                if let local = partido.marcadorLocal, let visita = partido.marcadorVisitante {
                    Text("\(local):\(visita)").font(.system(size: 64, weight: .black)).foregroundColor(.white).padding(.bottom, 30)
                } else {
                    Text("VS").font(.system(size: 40, weight: .black)).foregroundColor(.gray).padding(.bottom, 30)
                }
                EquipoColumn(nombre: partido.equipoVisitante.nombre)
            }
        }
    }
}

struct EquipoColumn: View {
    let nombre: String
    var urlSimulada: URL? {
        let formattedName = nombre.replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://ui-avatars.com/api/?name=\(formattedName)&background=random&color=fff&size=128&rounded=true&bold=true")
    }
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().stroke(Color.gray.opacity(0.3), lineWidth: 4).frame(width: 80, height: 80)
                KFImage(urlSimulada).placeholder { ProgressView().tint(.white) }.resizable().aspectRatio(contentMode: .fit).frame(width: 45).clipShape(Circle())
            }
            Text(nombre).font(.headline).fontWeight(.bold).foregroundColor(.white).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProbabilidadRow: View {
    let label: String
    let valor: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(Int(valor * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * valor, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .playOnce
    var contentMode: UIView.ContentMode = .scaleAspectFit
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView { UIView(frame: .zero) }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        uiView.subviews.forEach({ $0.removeFromSuperview() })
        let animationView = LottieAnimationView(name: filename)
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        uiView.addSubview(animationView)
        NSLayoutConstraint.activate([animationView.widthAnchor.constraint(equalTo: uiView.widthAnchor), animationView.heightAnchor.constraint(equalTo: uiView.heightAnchor)])
    }
}

// MARK: - PREVISUALIZACIÓN CON DATOS DE PRUEBA
struct DetallePartidoView_Previews: PreviewProvider {
    static var previews: some View {
        // Ejemplo: Argentina vs Canadá (Basado en el JSON)
        let mockPrediccion = PrediccionIA(
            posibleResultado: "2-0",
            probabilidadLocal: 0.80,
            probabilidadEmpate: 0.15,
            probabilidadVisitante: 0.05,
            topGoleadoresEstimados: [
                EstimacionJugador(nombre: "Lautaro Martínez", golesEstimados: 0.8, probabilidadGol: 0.65)
            ],
            factoresClave: ["Strong offense"]
        )
        
        let mockPartido = Partido(
            equipoLocal: Equipo(id: 5, nombre: "Argentina", codigoFIFA: "ARG", rankingIA: 2),
            equipoVisitante: Equipo(id: 6, nombre: "Canadá", codigoFIFA: "CAN", rankingIA: 49),
            marcadorLocal: 2,
            marcadorVisitante: 0,
            fecha: "14 Oct",
            estadio: "Mercedes-Benz",
            estado: .finalizado,
            prediccionIA: mockPrediccion
        )
        
        DetallePartidoView(partido: mockPartido)
            .preferredColorScheme(.dark)
    }
}
