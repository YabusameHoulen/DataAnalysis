using CairoMakie

fig3 = Figure()
xlim = 7
ylim = 5
xticks = vcat([x for x in -xlim:-1], [x for x in 1:xlim])
yticks = vcat([x for x in -ylim:-1], [x for x in 1:ylim])

# Create second axis for gridlines only
ax4 = Axis(
    fig3[1, 1],
    xticks=xticks,
    yticks=yticks,
    xticklabelsvisible=false,
    xticksvisible=false,
    yticklabelsvisible=false,
    yticksvisible=false,
)
hidespines!(ax4)

# Now create axis to be transformed
ax3 = Axis(
    fig3[1, 1],
    xticks=xticks,
    yticks=yticks,
    xgridvisible=false,
    ygridvisible=false,
)
hidespines!(ax3, :t, :r)

margin = 0.5
limits!(ax3, -xlim-margin, xlim+margin, -ylim-margin, ylim+margin)
limits!(ax4, -xlim-margin, xlim+margin, -ylim-margin, ylim+margin)

# Adjust aspect ratio based on limits
ax3.aspect=xlim/ylim
ax4.aspect=xlim/ylim

# Translate spines
x1, x2 = ax3.xaxis.attributes.endpoints[]
xl, xo = x1
xr = x2[1]
y1, y2 = ax3.yaxis.attributes.endpoints[]
yo, yb = y1
yt = y2[2]
new_xo = yb + (yt - yb)/2.0
new_yo = xl + (xr - xl)/2.0

ax3.xaxis.attributes.endpoints[] = ([xl, new_xo], [xr, new_xo])
ax3.yaxis.attributes.endpoints[] = ([new_yo, yb], [new_yo, yt])

# Label origin
text!(ax3, -0.4, -0.5, text="0", color=:black)

# Test lines
xs = LinRange(-xlim, xlim, 150)
lines!(ax3, xs, x->0.25x^2 - 4)
# lines!(ax3, [0, 0], [-5, 5], linestyle=:dash)
# lines!(ax3, [-7, 7], [0, 0], linestyle=:dash)
lines!(ax3, [-7, 7], [-4, -4], linestyle=:dash)

fig3
# save("center-spines.png", fig3)