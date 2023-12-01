
# T: type of time
@kwdef struct MapfResult{T<:Real}
    network::AbstractGraph
    paths::Vector{AgentPath{T}}
end
function MapfResult(
    network::AbstractGraph,
    vertices_result::Vector{Vector{Tuple{T,Int}}},
    edges_result::Vector{Vector{Tuple{T,Tuple{Int,Int}}}};
    vertex_binding::Bool=false,
) where {T<:Real}
    paths = [
        AgentPath(timed_vertices, timed_edges; vertex_binding=vertex_binding) for
        (timed_vertices, timed_edges) in zip(vertices_result, edges_result)
    ]

    return MapfResult{T}(network, paths)
end

nv(res::MapfResult) = nv(res.network)
ne(res::MapfResult) = ne(res.network)
nagents(res::MapfResult) = length(res.paths)
function timespan(res::MapfResult)
    return minimum(path -> first(path.time), res.paths),
    maximum(path -> last(path.time), res.paths)
end

function Base.show(io::IO, res::MapfResult)
    return println(
        io, "MapfResult with $(nagents(res)) agents on a {$(nv(res)), $(ne(res))}-graph"
    )
end

# A function: given a time `t`, return the position of each agent
function agent_location(res::MapfResult, t::Float64)::Vector{GraphLocation}
    return agent_location.(res.paths, t)
end
