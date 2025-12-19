using Luxor
using Colors
using Printf
using MathTeXEngine

# ==================================================
# CONSTANTES
# ==================================================
const CANVA_WIDTH, CANVA_HEIGHT = 1080, 1920
const BG_COLOR = "black"
const DURATION = 5.0  # segundos
const FPS = 25
const TOTAL_FRAMES = Int(DURATION * FPS)
const OUTPUT_NAME = "bernoulli-lemniscate"

# Dimensões matemáticas (proporcionais)
const PLOT_WIDTH = 800  # Mantém proporção matemática
const PLOT_HEIGHT = 400
const c = 250  # Parâmetro da lemniscata
const F1, F2 = Point(-c, 0), Point(c, 0)

# Número fixo de pontos para traçar a curva completa
const NUM_POINTS = 500

# ==================================================

function bernoulli_lemniscate(t, a)
    denom = 1 + sin(t)^2
    x = c * √2 * cos(t) / denom
    y = c * √2 * cos(t) * sin(t) / denom
    return Point(x, -y)  # Inverte y para coordenadas de tela
end



function backdrop(scene, frame)
    background(BG_COLOR)
    
    setcolor("white")

    # Título
    setfont("Open Sans Extrabold", 60)
    settext("Bernoulli's Lemniscate", Point(0, -0.6*CANVA_HEIGHT), 
         halign="center", valign="center")

    # Origem no centro da tela
    origin()
    
    # Eixos coordenados
    fontsize(40)
    setline(5)
    # Eixo x
    arrow(Point(-PLOT_WIDTH/2, 0), Point(PLOT_WIDTH/2, 0), 
          linewidth=4, arrowheadlength=20)
    text(L"x", Point(PLOT_WIDTH/2 + 20, 20), halign=:left)
    
    # Eixo y
    arrow(Point(0, PLOT_HEIGHT/2), Point(0, -PLOT_HEIGHT/2), 
          linewidth=4, arrowheadlength=20)
    text(L"y", Point(-20, -PLOT_HEIGHT/2 - 20), halign=:right)
end

function draw_pattern(scene, frame)
    origin()
    
    setcolor("white")
    fontsize(60)
    circle(F1, 6, :fill)
    text(L"F_1", Point(F1.x, 50), valign=:bottom)
    circle(F2, 6, :fill)
    text(L"F_2", Point(F2.x, 50), valign=:bottom)

    # Calcula quantos segmentos desenhar neste frame
    segments = Int(round(NUM_POINTS * frame / TOTAL_FRAMES))
    
    if segments > 1
        for i in 1:(segments-1)
            t1 = 2π * (i-1) / NUM_POINTS
            t2 = 2π * i / NUM_POINTS
            
            p1 = bernoulli_lemniscate(t1, a)
            p2 = bernoulli_lemniscate(t2, a)
            
            # Cor gradiente baseada na posição
            hue = 360 * i / NUM_POINTS
            setcolor(HSV(hue, 0.5, 1.0))
            setline(5)
            
            line(p1, p2, :stroke)
        end
    end
    
    # Ponto atual (último segmento em destaque)
    if segments > 0
        t_current = 2π * segments / NUM_POINTS
        p_current = bernoulli_lemniscate(t_current, a)
        
        setcolor("white")
        setline(6)
        circle(p_current, 6, :fill)
        text(L"P", Point(p_current.x, p_current.y - 50), valign=:top)

        setline(4)
        line(F1, p_current, :stroke)
        line(p_current, F2, :stroke)
    end
end

# Cria diretório de saída se não existir
output_dir = joinpath(pwd(), "bernoulli_lemniscate", "output")
!isdir(output_dir) && mkdir(output_dir)

# Cria a animação
movie = Movie(CANVA_WIDTH, CANVA_HEIGHT, OUTPUT_NAME, 1:TOTAL_FRAMES)

animate(movie, [
    Scene(movie, backdrop, 1:TOTAL_FRAMES),
    Scene(movie, draw_pattern, 1:TOTAL_FRAMES)
    ],
    creategif = true,
    pathname = joinpath(output_dir, "$(OUTPUT_NAME).gif"),
    framerate = FPS
)

println("Fim")