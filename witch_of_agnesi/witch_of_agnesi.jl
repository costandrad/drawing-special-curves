###############################################################################
# Witch of Agnesi —  Construction Animation
# Using Luxor.jl
#
# Author:      Igo da Costa Andrade
# GitHub:      https://github.com/costandrad
# TikTok:      https://www.tiktok.com/@costandrad.pi
# Repository:  https://github.com/costandrad/drawing-special-curves
# Date:        2025-12-10
#
# DESCRIPTION
#   This script generates a vertical-format animation (1080×1920, suitable for
#   TikTok/Reels) illustrating the geometric construction of the **Witch of Agnesi**.
#
#   Visual flow:
#     1) Background and Cartesian axes
#     2) Geometric construction
#     3) Progressive tracing of the Witch of Agnesi curve
#
# LICENSE
#   MIT License
###############################################################################

using Luxor, Colors, Printf, MathTeXEngine

# ============================================================================
# GLOBAL SETTINGS — CANVAS, TIMING, NAMING
# ============================================================================
CANVA_WIDTH, CANVA_HEIGHT = 1080, 1920
CURVE_NAME = "witch_of_agnesi"

DURATION = 5        # SECONDS
FPS = 25            # FRAMES PER SECOND
TOTAL_OF_FRAMES = FPS * DURATION


# ============================================================================
# GEOMETRIC PARAMETERS
# ============================================================================
X_AXIS, Y_AXIS = 0.4*CANVA_WIDTH, 0.25*CANVA_WIDTH
X_MIN, X_MAX = -X_AXIS, X_AXIS
Y_MIN, Y_MAX = 0.1*Y_AXIS, -Y_AXIS

# ============================================================================
# MATHEMATICAL MODEL
# ----------------------------------------------------------------------------
a = 0.4*Y_AXIS

function agnesi_curve(θ, a)
    A = Point(a * sin(2θ), -2a * (cos(θ))^2)
    N = Point(2a * tan(θ), -2a)
    P = Point(N.x, A.y)
    return A, N, P
end

points = [agnesi_curve(θ, a)[3] for θ ∈ π/3:(-(2π/3)/TOTAL_OF_FRAMES):-π/3]

# ============================================================================



# ============================================================================
# SCENE 1 — BACKGROUND AND CARTESIAN AXES
# ============================================================================

function backdrop(scene, frame)

    # Drawing defaults
    setcolor("white")
    setline(5)

    fontsize(50)
    fontface("Open Sans")

    # Background
    background("grey13")

    # ------------------------------------------------------------------------
    # Cartesian axes
    # ------------------------------------------------------------------------

    arrow(Point(X_MIN, 0), Point(X_MAX, 0),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{x}",
         Point(X_MAX, 50),
         halign = :center, valign = :center)

    arrow(Point(0, Y_MIN), Point(0, Y_MAX),
          linewidth = 5, arrowheadlength = 25)
    text(L"\mathrm{y}",
         Point(-50, Y_MAX),
         halign = :center, valign = :center)
end

# ============================================================================
# SCENE 2 — GEOMETRIC CONSTRUCTION AND ANNOTATIONS
# ============================================================================

function draw_geometry(scene, frame)
    θ = π/3 - ((2π/3) / TOTAL_OF_FRAMES) * frame

    fontsize(40)
    fontface("Open Sans")
    setcolor("white")

    # ------------------------------------------------------------------------
    # Key points
    # ------------------------------------------------------------------------

    O = Point(0, 0)
    M = Point(0, -2a)
    A, N, P = agnesi_curve(θ, a)


    # setcolor(HSV(rad2deg(θ), 0.5, 1.0))
    # oly(points[1:frame], :stroke, close=false)
    # setcolor(HSV(rad2deg(θ), 0.5, 1.0))
    for i in 2:TOTAL_OF_FRAMES
        setcolor(HSV(rad2deg(θ), 0.5, 1.0))
        p1, p2 = points[i-1], points[i]
        line(p1, p2, :stroke)
        setcolor("white")
    end
    

    setcolor("gray")
    circle(Point(0, -a), a, :stroke)
    line(Point(X_MIN, -2a), Point(X_MAX, -2a), :stroke)
    line(O, N, :stroke)
    line(A, P, :stroke)
    line(N, Point(N.x, 0), :stroke)
    setcolor("white")

    circle(O, 10, :fill)
    text(L"O",
        Point(-40, 50),
        halign=:center, valign=:center
    )
    
    circle(M, 10, :fill)
    text(L"M",
        Point(M.x-40, M.y-10),
        halign=:center, valign=:center
    )
    

    circle(A, 10, :fill)
    text(L"A",
        Point(A.x-30, A.y),
        halign=:center, valign=:center
    )

    circle(N, 10, :fill)
    text(L"N",
        Point(N.x-30, N.y-10),
        halign=:center, valign=:center
    )
    

    circle(P, 10, :fill)
    text(L"P",
        Point(P.x+30, P.y-10),
        halign=:center, valign=:center
    )


    # ------------------------------------------------------------------------
    # Title and descriptive text
    # ------------------------------------------------------------------------

    setfont("Open Sans Extrabold", 72)
    settext("Witch of Agnesi",
            Point(0, -0.4 * CANVA_HEIGHT),
            halign = "center", valign = "center")

    setfont("Open Sans", 45)
    if frame < 0.25*TOTAL_OF_FRAMES
    settext("The curve gained fame with Italian mathematician",
            Point(0, -0.35 * HEIGHT),
            halign = "center", valign = "center")

    settext("Maria Gaetana Agnesi in 1748, but its history",
            Point(0, -0.31 * HEIGHT),
            halign = "center", valign = "center")

    settext("includes earlier studies by Fermat, Grandi, and Newton.",
            Point(0, -0.27 * HEIGHT),
            halign = "center", valign = "center")

    settext("The name 'witch' arose from a mistaken",
            Point(0, -0.23 * HEIGHT),
            halign = "center", valign = "center")
    settext("translation of the technical term 'versoria'",
            Point(0, -0.19 * HEIGHT),
            halign = "center", valign = "center")
    end
        

    # ------------------------------------------------------------------------
    # Parametric equations
    # ------------------------------------------------------------------------

    text(L"\mathrm{x(\theta) = 2a\ \tan \theta }",
         Point(0, 0.25 * CANVA_HEIGHT),
         halign = :center, valign = :center)

    text(L"\mathrm{y(\theta) = 2a\ \cos^2 \theta }",
         Point(0, 0.30 * CANVA_HEIGHT),
         halign = :center, valign = :center)
end

# ============================================================================
# SCENE 3 — PROGRESSIVE TRACE OF THE ASTROID
# ============================================================================

function draw_curve(scene, frame)

end

# ============================================================================
# ANIMATION SETUP AND GIF EXPORT
# ============================================================================

movie = Movie(CANVA_WIDTH, CANVA_HEIGHT, CURVE_NAME, 1:TOTAL_OF_FRAMES)

frames_dir = joinpath(pwd(), "$(CURVE_NAME)/outputs/frames")
if isdir(frames_dir)
    rm(frames_dir; force=true, recursive=true)
end
mkdir(frames_dir)

animate(
    movie,
    [
        Scene(movie, backdrop, 1:TOTAL_OF_FRAMES),
        Scene(movie, draw_geometry, 1:TOTAL_OF_FRAMES),
        # Scene(movie, draw_curve,    1:TOTAL_FRAMES)
    ],
    creategif     = true,
    framerate     = FPS,
    tempdirectory = frames_dir,
    pathname      = joinpath(
        pwd(),
        "$(CURVE_NAME)/outputs/$(CURVE_NAME).gif"
    )
)

# ============================================================================
# OPTIONAL MP4 EXPORT (requires ffmpeg)
# ============================================================================

mp4_path = joinpath(pwd(), "$(CURVE_NAME)/outputs/$(CURVE_NAME).mp4")

cmd = `ffmpeg -y -r $FPS -i "$(frames_dir)/%10d.png" -c:v h264 -crf 0 "$(mp4_path)"`

println("\nGenerating MP4 using ffmpeg...\n")
println(cmd)

run(cmd)

println("\nMP4 generated at: $(mp4_path)")
