###############################################################################
# Witch of Agnesi Animation
#
# Gera uma animação da Witch of Agnesi utilizando Luxor.
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

const DURATION     = 5
const FRAME_RATE   = 20
const TOTAL_FRAMES = DURATION * FRAME_RATE

const CURVE_NAME = "witch_of_agnesi"

###############################################################################
# PARÂMETROS GEOMÉTRICOS E MATEMÁTICOS
###############################################################################

const X_AXIS = 0.4 * WIDTH
const Y_AXIS = 0.25 * WIDTH

const X_MIN, X_MAX = -X_AXIS, X_AXIS
const Y_MIN, Y_MAX =  0.1Y_AXIS, -Y_AXIS

const a = 0.4 * Y_AXIS   # parâmetro fundamental da curva

###############################################################################
# DEFINIÇÃO MATEMÁTICA DA CURVA
###############################################################################

"""
    agnesi_construction(θ, a)

Retorna os pontos geométricos envolvidos na construção da Witch of Agnesi:

- A: ponto sobre o círculo auxiliar
- N: interseção com a reta horizontal
- P: ponto da curva propriamente dita

A parametrização é baseada na construção clássica via tangente.
"""
function agnesi_construction(θ::Real, a::Real)
    A = Point(a * sin(2θ), -2a * cos(θ)^2)
    N = Point(2a * tan(θ), -2a)
    P = Point(N.x, A.y)
    return A, N, P
end

###############################################################################
# AMOSTRAGEM DOS PONTOS DA CURVA
###############################################################################

θ_min, θ_max =  π/3, -π/3
dθ = (θ_max - θ_min) / TOTAL_FRAMES

curve_points = [
    agnesi_construction(θ, a)[3]
    for θ in θ_min:dθ:θ_max
]

###############################################################################
# CENA 1 — FUNDO E EIXOS CARTESIANOS
###############################################################################

function draw_backdrop(scene, frame)
    background("gray13")

    setcolor("white")
    setline(5)

    fontsize(50)
    fontface("Open Sans")

    # -------------------------------------------------------------------------
    # Eixos cartesianos
    # -------------------------------------------------------------------------

    arrow(Point(X_MIN, 0), Point(X_MAX, 0),
          arrowheadlength = 25)
    text(L"\mathrm{x}",
         Point(X_MAX, 50),
         halign=:center, valign=:center)

    arrow(Point(0, Y_MIN), Point(0, Y_MAX),
          arrowheadlength = 25)
    text(L"\mathrm{y}",
         Point(-50, Y_MAX),
         halign=:center, valign=:center)
end

###############################################################################
# CENA 2 — CONSTRUÇÃO GEOMÉTRICA E TEXTOS
###############################################################################

function draw_geometry(scene, frame)
    θ = θ_min + dθ * frame

    fontsize(40)
    fontface("Open Sans")
    setcolor("white")

    # -------------------------------------------------------------------------
    # Pontos fundamentais
    # -------------------------------------------------------------------------

    O = Point(0, 0)
    M = Point(0, -2a)

    A, N, P = agnesi_construction(θ, a)

    # -------------------------------------------------------------------------
    # Traçado progressivo da curva
    # -------------------------------------------------------------------------

    setline(3)
    for i in 2:min(frame, length(curve_points))
        setcolor(HSV(rad2deg(θ) % 360, 0.6, 1.0))
        line(curve_points[i-1], curve_points[i], :stroke)
    end

    # -------------------------------------------------------------------------
    # Elementos da construção geométrica
    # -------------------------------------------------------------------------

    setcolor("gray")
    circle(Point(0, -a), a, :stroke)
    line(Point(X_MIN, -2a), Point(X_MAX, -2a), :stroke)
    line(O, N, :stroke)
    line(A, P, :stroke)
    line(N, Point(N.x, 0), :stroke)

    # Pontos destacados
    setcolor("white")
    foreach(p -> circle(p, 8, :fill), [O, M, A, N, P])

    # Rótulos
    text(L"O", O + Point(-30, 40))
    text(L"M", M + Point(-30, -10))
    text(L"A", A + Point(-30, 0))
    text(L"N", N + Point(-30, -10))
    text(L"P", P + Point(30, -10))

    # -------------------------------------------------------------------------
    # Título
    # -------------------------------------------------------------------------

    fontsize(70)
    fontface("Open Sans Extrabold")
    text("Witch of Agnesi",
         Point(0, -HEIGHT/2.5),
         halign=:center)

    # -------------------------------------------------------------------------
    # Texto descritivo
    # -------------------------------------------------------------------------

    fontsize(42)
    fontface("Open Sans")

    if frame < TOTAL_FRAMES ÷ 2
        text("Plane curve studied by Fermat, Grandi and Newton",
             Point(0, -HEIGHT/3.3),
             halign=:center)
        text("popularized by Maria Gaetana Agnesi in 1748",
             Point(0, -HEIGHT/3.3 + 60),
             halign=:center)
    else
        text("Its name arose from a mistranslation of",
             Point(0, -HEIGHT/3.3),
             halign=:center)
        text("the Italian term 'versoria'",
             Point(0, -HEIGHT/3.3 + 60),
             halign=:center)
    end

    # -------------------------------------------------------------------------
    # Equações paramétricas
    # -------------------------------------------------------------------------

    fontsize(44)
    fontface("Open Sans Extrabold")

    text(L"\mathrm{x(\theta) = 2a\tan\theta}",
         Point(0, HEIGHT/4.5),
         halign=:center)

    text(L"\mathrm{y(\theta) = 2a\cos^2\theta}",
         Point(0, HEIGHT/4.5 + 90),
         halign=:center)
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
        Scene(movie, draw_geometry, 1:TOTAL_FRAMES)
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
run(cmd)

println("\nMP4 generated at: $(mp4_path)")
