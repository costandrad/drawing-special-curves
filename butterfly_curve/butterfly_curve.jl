###############################################################################
# Butterfly Curve Animation
#
# Gera uma animação da Curva da Borboleta (Butterfly Curve) utilizando Luxor.
# O resultado final é exportado como GIF e MP4.
#
# Dependências:
#   Luxor, Colors, Printf, MathTeXEngine
###############################################################################

using Luxor
using Colors
using Printf
using MathTeXEngine

###############################################################################
# CONFIGURAÇÕES GERAIS DO VÍDEO
###############################################################################

const WIDTH  = 1080                 # Largura do canvas (px)
const HEIGHT = 1920                 # Altura do canvas (px)

const DURATION     = 10             # Duração do vídeo (s)
const FRAME_RATE   = 120            # Quadros por segundo
const TOTAL_FRAMES = DURATION * FRAME_RATE

const CURVE_NAME = "butterfly_curve"

###############################################################################
# DEFINIÇÃO MATEMÁTICA DA CURVA
###############################################################################

"""
    butterfly(θ) -> Point

Retorna um ponto `(x, y)` da Curva da Borboleta para um dado parâmetro `θ`.

A curva é definida em coordenadas polares por uma expressão transcendental,
sendo convertida internamente para coordenadas cartesianas.

O sinal negativo em `y` é usado para adequar a orientação ao sistema
de coordenadas do Luxor.
"""
function butterfly(θ::Real)::Point
    r = (WIDTH / 10) * (
        exp(sin(θ)) -
        2 * cos(4θ) -
        (sin((2θ - π) / 24))^5
    )

    x =  r * cos(θ)
    y = -r * sin(θ)

    return Point(x, y)
end

###############################################################################
# CENA 1 — FUNDO, TEXTOS E EIXOS
###############################################################################

"""
    draw_backdrop(scene, frame)

Desenha o fundo da animação:
- cor de fundo;
- título e textos explicativos;
- equações paramétricas e polares;
- eixos cartesianos.

O conteúdo textual muda dinamicamente na metade da animação.
"""
function draw_backdrop(scene, frame)
    background("gray10")

    # -------------------------------------------------------------------------
    # TÍTULO
    # -------------------------------------------------------------------------
    setcolor("white")
    setline(3)
    fontsize(60)
    fontface("Open Sans Extrabold")

    text(
        "Butterfly Curve",
        Point(0, -HEIGHT / 3),
        halign = :center,
        valign = :center
    )

    # -------------------------------------------------------------------------
    # TEXTO DESCRITIVO
    # -------------------------------------------------------------------------
    fontface("Open Sans")
    fontsize(40)

    if frame < TOTAL_FRAMES / 2
        text("The butterfly curve is a beautiful, complex curve in",
             Point(0, -HEIGHT/3 +  90), halign=:center, valign=:center)
        text("mathematics, famously defined by parametric equations",
             Point(0, -HEIGHT/3 + 150), halign=:center, valign=:center)
        text("that create a shape resembling a butterfly with delicate",
             Point(0, -HEIGHT/3 + 210), halign=:center, valign=:center)
    else
        text("wings, discovered by Temple H. Fay in 1989.",
             Point(0, -HEIGHT/3 +  90), halign=:center, valign=:center)
        text("Transcendental version uses exponential and",
             Point(0, -HEIGHT/3 + 150), halign=:center, valign=:center)
        text("trigonometric functions to generate butterflies.",
             Point(0, -HEIGHT/3 + 210), halign=:center, valign=:center)
    end

    # -------------------------------------------------------------------------
    # EQUAÇÕES
    # -------------------------------------------------------------------------
    fontsize(45)
    fontface("Open Sans Extrabold")

    if frame < TOTAL_FRAMES / 2
        text("Parametric Equations",
             Point(0, HEIGHT/5), halign=:center, valign=:center)

        text(
            L"\mathrm{x(t)=\sin\ t \ \left(e^{\cos\ t}-2\cos\ 4t-\sin^5(t/12)\right)}",
            Point(0, HEIGHT/5 + 100), halign=:center, valign=:center
        )

        text(
            L"\mathrm{y(t)=\cos\ t \ \left(e^{\cos\ t}-2\cos\ 4t-\sin^5(t/12)\right)}",
            Point(0, HEIGHT/5 + 160), halign=:center, valign=:center
        )

        text(
            L"\mathrm{0\ \leq \ t \ \leq \ 12\pi}",
            Point(0, HEIGHT/5 + 220), halign=:center, valign=:center
        )
    else
        text("Polar Equation",
             Point(0, HEIGHT/5), halign=:center, valign=:center)

        text(
            L"\mathrm{r(\theta)=e^{\sin\ \theta}-2\cos\ 4\theta+\sin^5\left(\frac{2\theta-\pi}{24}\right)}",
            Point(0, HEIGHT/5 + 100), halign=:center, valign=:center
        )
    end

    # -------------------------------------------------------------------------
    # EIXOS CARTESIANOS
    # -------------------------------------------------------------------------
    arrow(Point(-0.35WIDTH, 0), Point(0.35WIDTH, 0),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{x}", Point(0.35WIDTH, 50),
         halign=:center, valign=:center)

    arrow(Point(0, 0.3WIDTH), Point(0, -0.35WIDTH),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{y}", Point(-50, -0.35WIDTH + 25),
         halign=:center, valign=:center)
end

###############################################################################
# CENA 2 — DESENHO PROGRESSIVO DA CURVA
###############################################################################

"""
    draw_pattern(scene, frame)

Desenha incrementalmente a Curva da Borboleta até o quadro atual,
criando o efeito de crescimento ao longo do tempo.

A coloração varia suavemente com o parâmetro angular.
"""
function draw_pattern(scene, frame)
    dθ = 12π / TOTAL_FRAMES

    for i in 1:frame
        θ₁ = dθ * (i - 1)
        θ₂ = dθ * i

        P1 = butterfly(θ₁)
        P2 = butterfly(θ₂)

        setcolor(HSV(rad2deg(θ₁), 0.5, 1.0))
        line(P1, P2, :stroke)
    end
end

###############################################################################
# CRIAÇÃO DO FILME E ANIMAÇÃO
###############################################################################

movie = Movie(WIDTH, HEIGHT, CURVE_NAME, 1:TOTAL_FRAMES)

frames_dir = joinpath(pwd(), "$(CURVE_NAME)/outputs/frames")

# Limpa frames antigos, se existirem
if isdir(frames_dir)
    rm(frames_dir; force = true, recursive = true)
end
mkdir(frames_dir)

animate(
    movie,
    [
        Scene(movie, draw_backdrop, 1:TOTAL_FRAMES),
        Scene(movie, draw_pattern,  1:TOTAL_FRAMES)
    ],
    creategif     = true,
    framerate     = FRAME_RATE,
    tempdirectory = frames_dir,
    pathname      = joinpath(
        pwd(), "$(CURVE_NAME)/outputs/$(CURVE_NAME).gif"
    )
)

###############################################################################
# EXPORTAÇÃO PARA MP4 (FFMPEG)
###############################################################################

mp4_path = joinpath(pwd(), "$(CURVE_NAME)/outputs/$(CURVE_NAME).mp4")

cmd = `ffmpeg -y -r $FRAME_RATE -i "$(frames_dir)/%10d.png" -c:v h264 -crf 0 "$(mp4_path)"`

println("\nGenerating MP4 using ffmpeg...\n")
println(cmd)

run(cmd)

println("\nMP4 generated at: $(mp4_path)")
