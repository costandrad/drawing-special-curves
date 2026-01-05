###############################################################################
# Folium of Descartes Animation
#
# Gera uma animação da Folium of Descartes utilizando Luxor.
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

const WIDTH  = 1080
const HEIGHT = 1920

const DURATION     = 10
const FRAME_RATE   = 30
const TOTAL_FRAMES = DURATION * FRAME_RATE

const CURVE_NAME = "folium_of_descartes"

###############################################################################
# PARÂMETROS MATEMÁTICOS
###############################################################################

const a = WIDTH / 10   # parâmetro da curva (escala geométrica)

###############################################################################
# DEFINIÇÃO MATEMÁTICA DA CURVA
###############################################################################

"""
    folium_of_descartes(θ) -> Point

Retorna um ponto `(x, y)` da Folium of Descartes para um dado parâmetro `θ`.

Equação polar:
    r(θ) = (3a sinθ cosθ) / (sin³θ + cos³θ)

A conversão para coordenadas cartesianas é feita internamente.
O sinal negativo em `y` ajusta a orientação ao sistema do Luxor.
"""
function folium_of_descartes(θ::Real)::Point
    denom = sin(θ)^3 + cos(θ)^3

    if abs(denom) < 1e-6
        return Point(0, 0)
    end

    r = 3a * sin(θ) * cos(θ) / denom

    x =  r * cos(θ)
    y = -r * sin(θ)

    return Point(x, y)
end

###############################################################################
# CENA 1 — FUNDO, TEXTOS E EIXOS
###############################################################################

function draw_backdrop(scene, frame)
    background("gray10")

    # -------------------------------------------------------------------------
    # TÍTULO
    # -------------------------------------------------------------------------
    setcolor("white")
    fontsize(60)
    fontface("Open Sans Extrabold")

    text(
        "Folium of Descartes",
        Point(0, -HEIGHT / 3),
        halign = :center,
        valign = :center
    )

    # -------------------------------------------------------------------------
    # TEXTO DESCRITIVO
    # -------------------------------------------------------------------------
    fontface("Open Sans")
    fontsize(38)

    if frame < TOTAL_FRAMES ÷ 2
        text("Cubic algebraic curve introduced by René Descartes (1638)",
             Point(0, -HEIGHT/3 + 90), halign=:center)
        text("defined by a symmetric relation between x and y",
             Point(0, -HEIGHT/3 + 150), halign=:center)
    else
        text("Exhibits a nodal singularity at the origin",
             Point(0, -HEIGHT/3 + 90), halign=:center)
        text("and elegant rotational geometry",
             Point(0, -HEIGHT/3 + 150), halign=:center)
    end

    # -------------------------------------------------------------------------
    # EQUAÇÕES
    # -------------------------------------------------------------------------
    fontsize(44)
    fontface("Open Sans Extrabold")

    if frame < TOTAL_FRAMES ÷ 3
        text("Cartesian Equation",
             Point(0, HEIGHT/5), halign=:center)

        text(
            L"\mathrm{x^3 + y^3 = 3axy}",
            Point(0, HEIGHT/5 + 100), halign=:center
        )

    elseif frame < 2TOTAL_FRAMES ÷ 3
        text("Parametric Equations",
             Point(0, HEIGHT/5), halign=:center)

        text(
            L"\mathrm{x(t)=\frac{3at}{1+t^3}}",
            Point(0, HEIGHT/5 + 100), halign=:center
        )
        text(
            L"\mathrm{y(t)=\frac{3at^2}{1+t^3}}",
            Point(0, HEIGHT/5 + 225), halign=:center
        )

    else
        text("Polar Equation",
             Point(0, HEIGHT/5), halign=:center)

        text(
            L"\mathrm{r(\theta)=\frac{3a\sin\ \theta \ \cos \ \theta}{\sin^3\ \theta+\cos^3 \ \theta}}",
            Point(0, HEIGHT/5 + 100), halign=:center
        )
    end

    # -------------------------------------------------------------------------
    # EIXOS CARTESIANOS
    # -------------------------------------------------------------------------
    setline(4)

    arrow(Point(-0.35WIDTH, 0), Point(0.35WIDTH, 0),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{x}", Point(0.35WIDTH, 40))

    arrow(Point(0, 0.3WIDTH), Point(0, -0.35WIDTH),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{y}", Point(-40, -0.36WIDTH + 40))
end

###############################################################################
# CENA 2 — DESENHO PROGRESSIVO DA CURVA
###############################################################################

function draw_pattern(scene, frame)
    θ_min = -0.2π
    θ_max =  0.7π
    dθ    = (θ_max - θ_min) / TOTAL_FRAMES

    setline(5)

    for i in 1:frame
        θ₁ = θ_min + dθ * (i - 1)
        θ₂ = θ₁ + dθ

        P1 = folium_of_descartes(θ₁)
        P2 = folium_of_descartes(θ₂)

        setcolor(HSV(rad2deg(θ₁) % 360, 0.6, 1.0))
        line(P1, P2, :stroke)
    end
end

###############################################################################
# CRIAÇÃO DA ANIMAÇÃO
###############################################################################

movie = Movie(WIDTH, HEIGHT, CURVE_NAME, 1:TOTAL_FRAMES)

frames_dir = joinpath(pwd(), "$(CURVE_NAME)/outputs/frames")

if isdir(frames_dir)
    rm(frames_dir; force=true, recursive=true)
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
# EXPORTAÇÃO PARA MP4
###############################################################################

mp4_path = joinpath(pwd(), "$(CURVE_NAME)/outputs/$(CURVE_NAME).mp4")

cmd = `ffmpeg -y -r $FRAME_RATE -i "$(frames_dir)/%10d.png" -c:v h264 -crf 0 "$(mp4_path)"`

println("\nGenerating MP4 using ffmpeg...\n")
run(cmd)

println("\nMP4 generated at: $(mp4_path)")
