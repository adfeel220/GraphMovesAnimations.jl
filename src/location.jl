
const GraphLocation = Tuple{Int,Int,Float64}

source(loc::GraphLocation)::Int = loc[1]
target(loc::GraphLocation)::Int = loc[2]
progress(loc::GraphLocation)::Float64 = loc[3]

is_valid(loc::GraphLocation)::Bool = !(source(loc) <= 0 || target(loc) <= 0 || progress(loc) < 0.0 || progress(loc) > 1.0)
is_vertex(loc::GraphLocation)::Bool = source(loc) == target(loc)


function graphloc_to_phyloc(graph_loc::GraphLocation, layout::Vector{Point2{Float64}})
    if !is_valid(graph_loc)
        return Point2{Float64}(NaN, NaN)
    end
    if is_vertex(graph_loc)
        return layout[source(graph_loc)]
    end

    source_point = layout[source(graph_loc)]
    target_point = layout[target(graph_loc)]
    prog = progress(graph_loc)

    return (1.0 - prog) * source_point + prog * target_point
end

function graphloc_to_phyloc(
    graph_loc::Vector{GraphLocation}, layout::Vector{Point2{Float64}}
)
    return [graphloc_to_phyloc(gl, layout) for gl in graph_loc]
end