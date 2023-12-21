
function plot_interactive(
    result::MapfResult,
    layout::Vector{Point2{Float64}}=Spring()(result.network);
    fontsize::Int=24,
    deltatime::Float64=0.01,
    kwargs...,
)
    fig = Figure(; fontsize=fontsize)
    ax = Axis(fig[1, 1]; title="Animation of Agent Movements")

    # Prepare controlling sliders
    min_time, max_time = timespan(result)
    sliders_ax = SliderGrid(
        fig[2, 1],
        (label="Time", range=min_time:deltatime:max_time, startvalue=min_time),
        (label="Size", range=2:1:50, startvalue=12),
        (label="Edge Curve", range=0.0:0.01:0.5, startvalue=0.02),
    )

    # Control time
    physical_locations = lift(sliders_ax.sliders[1].value) do time_value
        graphical_locations = agent_location(result, time_value)
        graphloc_to_phyloc(graphical_locations, layout)
    end

    # Control other plotting attributes
    node_size = lift(sliders_ax.sliders[2].value) do val
        val
    end
    agent_size = lift(sliders_ax.sliders[2].value) do val
        val - 1
    end
    edge_curve = lift(sliders_ax.sliders[3].value) do val
        val
    end

    # Main scene
    graphplot!(
        ax,
        result.network;
        nlabels=string.(1:nv(result)),
        node_size=node_size,
        layout=layout,
        curve_distance=edge_curve,
        kwargs...,
    )

    scatter!(ax, physical_locations; color=:red, marker=:star5, markersize=agent_size)
    text!(
        ax,
        physical_locations;
        text=string.(1:nagents(result)),
        fontsize=node_size,
        align=(:right, :baseline),
        offset=(-5, 0),
        color=:red,
    )

    return fig, ax
end

function plot_interactive(
    filename::String;
    vertex_binding::Bool=false,
    fontsize::Int=24,
    deltatime::Float64=0.01,
    kwargs...,
)
    data = load(filename)
    @assert haskey(data, "network") "A MAPF result file must have key \"network\""
    @assert haskey(data, "vertices_result") "A MAPF result file must have key \"vertices_result\""
    @assert haskey(data, "edges_result") "A MAPF result file must have key \"edges_result\""
    stay_after_arrival = get(data, "stay_after_arrival", false)

    network = data["network"]
    vertices_result = data["vertices_result"]
    edges_result = data["edges_result"]

    mapf_result = MapfResult(
        network,
        vertices_result,
        edges_result;
        vertex_binding=vertex_binding,
        stay_after_arrival=stay_after_arrival,
    )

    if haskey(data, "layout")
        return plot_interactive(
            mapf_result, data["layout"]; fontsize=fontsize, deltatime=deltatime, kwargs...
        )
    else
        return plot_interactive(
            mapf_result; fontsize=fontsize, deltatime=deltatime, kwargs...
        )
    end
end
