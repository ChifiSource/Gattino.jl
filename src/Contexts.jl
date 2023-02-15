mutable struct Context <: Toolips.Modifier
    window::Component{:svg}
    uuid::String
    n::Int64
    layers::Dict{String, UnitRange{Int64}}
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Context(window::Component{:svg}, margin::Pair{Int64, Int644}) = new(window,
    parse(window[:width], Int64) => parse(window[:height], int64), margin)
    function Context(width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0)
        uuid::String = randstring(10)
        window::Component{:svg} = svg("$uuid-window", width = width,
        height = height)
        Context(window, 0, 1280 => 720,  margin)::Context
    end
end

function draw!(id::String, c::Context, comps::Vector{<:Servable})
    current_len::Int64 = length(c.window[:children])
    comp_len::Int64 = length(comps)
    c.window[:children] = vcat(c.window[:children], comps)
    c.layers[id] = current_len + 1:current_len + comp_len
end

function context!(f::Function, window::Component{:svg},
    margin::Pair{Int64, Int64} = 0 => 0)
    context::Context = Context(window, margin)
    f(context)
end

context(args ...; keyargs ...) = Context(args ..., keyargs ...)

function context!(f::Function, window::Component{:svg})

end

function line!(context::Context, x::Vector{Number}, y::Vector{Number})

end

function grid!(context::Context, n::Int64 = 4)
    division_amountx::Int64 = context.dim[1] / n
    division_amounty::Int64 = context.dim[2] / n
    push!(contexts.layers, context.)
    context.n += length(xlines)
    xlines = Vector{Servable}([begin
        l::Component{:line} = line("context$(context.n)",
        "x1" => string(xcoord), "y1" => string(context.dim[2]),
        "x2" => string(xcoord), "y2" => string(0 + context.margin[2]))
    end for xcoord in range(1 + context.margin[1], context.dim[1],
    step = division_amountx)])

end

function points!(context::Context, x::Vector{<:Number}, y::Vector{<:Number},
     p::Pair{String, Any} ...; args ...)
    circs::Vector{Servable} = Vector{Servable}([begin
        context.n += 1
        circle("context$(context.n)", cx = string(pointx), cy = string(pointy), p...,
        args ...)
    end for (pointx, pointy) in zip(x, y)])
    context.window[:children] = vcat(context.window[:children], circs)
end

function trendline!(context::Context, styles::Pair{String, String} ...)

end

function edit!(c::Context)

end

function drop!(c::Context)

end

function histo!(x::)

end
