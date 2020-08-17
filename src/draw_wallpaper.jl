using Revise

includet("src/double_pendulum.jl")

# system parameters
m = [1.0; 1.0]
l = [1.0; 1.0]
g = 1.62
y0 = [pi/1.4; 0; pi/1.4; 0]
p = [m[1]; m[2]; l[1]; l[2]; g]
t = (0.0, 100.0)

sol = solve_double_pendulum(y0, p, t)
path = convert_coordinates(sol, l)
ipath = interpolate_path(path, t, sol.t, 0.001)

start_time = 3.0
end_time = 43.3
lab_struct = ["<b>parameters</b>", "g = $g", "l = $l", "m = $m"]
lab_state = ["<b>system state</b>", "y<sub>0</sub> = $(round.(y0*100)/100)", "t = $(round(end_time*100)/100)"]

wallpaper(ipath, 3.0, 43.0, "img/test.png", lab_struct, lab_state)

