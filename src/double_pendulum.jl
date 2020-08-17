using DifferentialEquations, Plots, Dierckx, Luxor

function double_pendulum(du, u, p, t)
  m = p[1:2]
  l = p[3:4]
  g = p[5]

  c = cos(u[1] - u[3])
  s = sin(u[1] - u[3])

  du[1] = u[2]
  du[2] = (m[2]*g*sin(u[3])*c - m[2]*s*(l[1]*c*u[2]^2 + l[2]*u[4]^2) - (m[1] + m[2])*g*sin(u[1])) / (l[1]*(m[1] + m[2]*s^2))
  du[3] = u[4];
  du[4] = ((m[1] + m[2])*(l[1]*u[2]^2*s - g*sin(u[3]) + g*sin(u[1])*c) + m[2]*l[2]*u[4]^2*s*c) / (l[2]*(m[1] + m[2]*s^2))
end

function solve_double_pendulum(y0, p, t)
  ode = ODEProblem(double_pendulum, y0, t, p)
  solution = solve(ode, Vern7(), reltol = 1e-6)
  return solution
end

function convert_coordinates(solution, l)
  p1 = [l[1] * sin.(solution[1, :]), -l[1] * cos.(solution[1, :])]
  p2 = [p1[1] + l[2] * sin.(solution[3, :]), p1[2] - l[2] * cos.(solution[3, :])]
  return p2
end

function interpolate_path(p, t, knots, stepsize = 0.01)
  t_steps = minimum(t):stepsize:maximum(t)
  sp = [Spline1D(knots, p[1]), Spline1D(knots, p[2])]
  interp = -[sp[1](t_steps), sp[2](t_steps)]
  return [collect(t_steps), interp]
end

# plotting defaults
colors = Dict(
  "background" => "#3F403F",
  "line" => "#e9ecef",
  "label" => "#ced4da",
  "dot" => "#F8F9FA"
)

sizes = Dict(
  "image" => [2560*2, 1440*2],
  "line" => 2*2,
  "dot" => 4*2,
  "label" => 16*2
)

spacing = Dict(
  "margin" => 30*2,
  "lineheight" => sizes["label"] * 1.4,
  "offset" => -100*2
)

function wallpaper(ipath, t_start, t_end, filename, label_left = [""], label_right = [""], title = "", scale = 200, decay_rate = 2, colors = colors, sizes = sizes, spacing = spacing)
  t = ipath[1]
  path = ipath[2]
  
  idx = [(t[i] >= t_start) & (t[i] <= t_end) ? i : 0 for i = 1:size(t)[1]]
  idx = idx[idx .!= 0]

  # plotting parameters
  opacity = collect(range(0, 1, length = size(idx)[1])) .^ decay_rate

  # plotting
  Drawing(sizes["image"][1], sizes["image"][2], filename)
  origin()
  circle(O, 50, :stroke)
  offset = Point(0, spacing["offset"])
  background(colors["background"])
  sethue(colors["line"])
  setline(sizes["line"])

  for i = 2:size(idx)[1]
    setopacity(opacity[i - 1])
    sethue(colors["line"])

    p1 = Point(path[1][idx[i - 1]], path[2][idx[i - 1]]) * scale + offset
    p2 = Point(path[1][idx[i]], path[2][idx[i]]) * scale + offset
    line(p1, p2, :stroke)
  end
  # Pendulum state
  sethue(colors["dot"])
  setopacity(1)
  setline(sizes["line"])
  state = Point(path[1][last(idx)], path[2][last(idx)]) * scale + offset
  circle(state, sizes["dot"], :fill)
  
  # title
  setfont("Space Mono", sizes["label"])
  sethue(colors["label"])
  pos = Point(0, -2*scale - spacing["margin"]) + offset
  settext("<b>$(title)</b>", pos, halign = "center", valign = "center", markup = true)

  # captions
  setfont("Space Mono", sizes["label"])
  sethue(colors["label"])
  pos = Point(-2*scale, 2*scale + spacing["margin"]) + offset
  for i = 1:size(label_left)[1]
    settext(label_left[i], pos + Point(0, i * spacing["lineheight"]); halign = "left", valign = "center", markup = true)
  end

  pos = Point(2*scale, 2*scale + spacing["margin"]) + offset
  for i = 1:size(label_right)[1]
    settext(label_right[i], pos + Point(0, i * spacing["lineheight"]); halign = "right", valign = "center", markup = true)
  end

  finish()
end

