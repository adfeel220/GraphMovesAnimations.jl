module GraphMovesAnimations

using Graphs: AbstractGraph
using GLMakie: Figure, Axis, SliderGrid, scatter!, text!
using GLMakie: Point2, lift
using GraphMakie: graphplot!
using GraphMakie: NetworkLayout.Spring
using JLD2: load

import Graphs: nv, ne

export MapfResult, plot_interactive

include("location.jl")
include("path.jl")
include("result.jl")
include("plot.jl")

end
