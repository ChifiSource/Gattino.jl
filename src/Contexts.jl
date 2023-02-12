mutable struct Context <: Toolips.Modifier
    window::Component{:svg}
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Context(window::Component{:svg}, margin::Pair{Int64, Int644}) = new(window,
    parse(window[:width], Int64) => parse(window[:height], int64), margin)
    function Context(width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0)
        window::Component{:svg} = svg(randstring(10), width = width,
        height = height)
        Context(window, margin)::Context
    end
end

function context!(f::Function, window::Component{:svg},
    margin::Pair{Int64, Int64} = 0 => 0)

end

function grid!(window::Component{:svg}; styles::Pair{String, String} ...)

end

function points!(window::Component{:svg}, styles::Pair{String, String} ...)

end

function trendline!(window::Component{:svg}, styles::Pair{String, String} ...)

end
