# Description: Custom composite type to store an MAPF answer

function add_adjacent_event!(
    source_events::Vector, target_events::Vector; back::Bool=true
)::Bool
    candidate = back ? last(target_events) : first(target_events)

    # Search to append a vertex (must be an edge starting/ending from this vertex)
    if isa(candidate, Int)
        attach_event_id = 0
        # require an edge start with current candidate
        for (idx, ev) in enumerate(source_events)
            if isa(ev, Tuple{Int,Int}) &&
                (back && ev[1] == candidate || !back && ev[2] == candidate)
                if back
                    push!(target_events, ev)
                else
                    pushfirst!(target_events, ev)
                end
                popat!(source_events, idx)

                return true
            end
        end

    elseif isa(candidate, Tuple{Int,Int})
        attach_event_id = 0
        # search for vertex
        for (idx, ev) in enumerate(source_events)
            if isa(ev, Int) && (back && ev == candidate[2] || !back && ev == candidate[1])
                if back
                    push!(target_events, ev)
                else
                    pushfirst!(target_events, ev)
                end
                popat!(source_events, idx)

                return true
            end
        end
        # search for edge
        for (idx, ev) in enumerate(source_events)
            if isa(ev, Tuple{Int,Int}) &&
                (back && ev[1] == candidate[2] || !back && ev[2] == candidate[1])
                if back
                    push!(target_events, ev)
                else
                    pushfirst!(target_events, ev)
                end
                popat!(source_events, idx)

                return true
            end
        end
    else
        error(
            "Type of event \"$(typeof(candidate))\" is neither a vertex (`Int`) nor an edge (`Tuple{Int,Int}`)",
        )
    end

    return false
end

function order_events(locations::Vector)
    if length(locations) <= 1
        return locations
    end

    remain_events = copy(locations)
    ordered_locations = Vector{Union{Int,Tuple{Int,Int}}}(undef, 1)
    first_vertex_idx = first(
        id for id in 1:length(remain_events) if isa(remain_events[id], Int)
    )
    ordered_locations[1] = popat!(remain_events, first_vertex_idx)

    while length(remain_events) > 0
        # search to append to back
        if !add_adjacent_event!(remain_events, ordered_locations; back=true) &&
            !add_adjacent_event!(remain_events, ordered_locations; back=false)
            error(
                "Impossible to reorder $locations into a chained events, cannot find any candidate from $remain_events to append to $ordered_locations",
            )
        end
    end

    return ordered_locations
end

# T: type of time
@kwdef struct AgentPath{T<:Real}
    time::Vector{T}  # arrival time of the corresponding location
    location::Vector{Union{Int,Tuple{Int,Int}}}
end
function AgentPath(
    timed_vertices::Vector{Tuple{T,Int}},
    timed_edges::Vector{Tuple{T,Tuple{Int,Int}}};
    vertex_binding::Bool=false,
) where {T<:Real}
    if vertex_binding
        timed_events = timed_vertices
    else
        timed_events = sort(reduce(vcat, [timed_vertices, timed_edges]); by=(x -> x[1]))
    end

    time = [tev[1] for tev in timed_events]
    events = similar(timed_events, Union{Int,Tuple{Int,Int}})
    id = 1
    while id <= length(timed_events)
        next_id = id + 1
        current_time = timed_events[id][1]
        while next_id <= length(timed_events) && current_time == timed_events[next_id][1]
            next_id += 1
        end

        events[id:(next_id - 1)] = order_events([
            tev[2] for tev in timed_events[id:(next_id - 1)]
        ])

        id = next_id
    end

    return AgentPath{T}(; time=time, location=events)
end
Base.length(ap::AgentPath) = length(ap.time)

Base.show(io::IO, ap::AgentPath) = begin
    text = "$(length(ap))-step AgentPath"
    for (t, loc) in zip(ap.time, ap.location)
        text *= "\nt=$t,\tat $loc"
    end
    println(io::IO, text)
end

# a function: given a time `t`, return the position of agent (with respect to vertices)
# return a tuple (from, to, status)
function agent_location(path::AgentPath, t::Float64)::GraphLocation
    after_events = [(event_id, tm) for (event_id, tm) in enumerate(path.time) if tm > t]
    if length(after_events) == 0
        return last(path.location), last(path.location), 1.0
    elseif length(after_events) == length(path)
        return -1, -1, 0.0
    end

    immediate_event_id, immediate_time = first(after_events)
    previous_time = path.time[immediate_event_id - 1]
    progress = (t - previous_time) / (immediate_time - previous_time)

    previous_loc = path.location[immediate_event_id - 1]
    if isa(previous_loc, Tuple)
        return previous_loc..., progress
    end

    immediate_loc = path.location[immediate_event_id]
    if isa(immediate_loc, Tuple)
        return previous_loc, previous_loc, progress
    end

    return previous_loc, immediate_loc, progress
end
