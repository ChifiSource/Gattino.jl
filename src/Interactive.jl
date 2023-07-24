mutable struct PlotModifier <: ToolipsSession.AbstractComponentModifier
    con::Context
    changes::Vector{String}
end

function open!(f::Function, cl::ClientModifier, c::Context)
    
end