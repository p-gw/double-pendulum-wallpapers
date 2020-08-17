using Revise

includet("src/double_pendulum.jl")

function rsimplex(x) 
  a = rand(x)
  return [a, 2 - a]
end

gravities = Dict(
  "sun" => 275.0,
  "mercury" => 3.7,
  "venus" => 8.9,
  "earth" => 9.8,
  "moon" => 1.6,
  "mars" => 3.7,
  "phobos" => 0.006,
  "deimos" => 0.0033,
  "jupiter" => 25.0,
  "ganymede" => 1.4,
  "europa" => 1.3,
  "saturn" => 10.4,
  "uranus" => 8.9,
  "neptune" => 11.0
)

masses = 0.5:0.01:1.5
lengths = 0.5:0.01:1.5
positions = 0:0.01:2*pi

function random_wallpaper(masses, lengths, gravities, positions, filename) 
  gravity = rand(gravities)
  m = rsimplex(masses)
  l = rsimplex(lengths)
  g = gravity[2]
  position = rand(positions, 2)

  y0 = [position[1]; 0; position[2]; 0]
  p = [m[1]; m[2]; l[1]; l[2]; g]
  t = (0.0, 100.0)

  start_time = rand(minimum(t):0.01:(maximum(t) - 40))
  end_time = start_time + 40

  sol = solve_double_pendulum(y0, p, t)
  path = convert_coordinates(sol, l)
  ipath = interpolate_path(path, t, sol.t, 1e-4)

  lab_struct = ["<b>parameters</b>", "g = $g", "l = $(round.(l*100)/100)", "m = $(round.(m*100)/100)"]
  lab_state = ["<b>system state</b>", "y<sub>0</sub> = $(round.(y0[[1, 3]]*100)/100)", "t = $(round(end_time*100)/100)"]
  @info m, l, g, y0, t 
  wallpaper(ipath, start_time, end_time, filename, lab_struct, lab_state, gravity[1])
end

