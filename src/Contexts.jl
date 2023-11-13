
"""
### abstract type AbstractContext <: Toolips.Modifier
AbstractContexts are `Modifiers` that can be used to draw inside of a given frame.
These contexts can be drawn on using the `draw!` method and keep track of
different elements inside of the Context.
##### Consistencies
- window::Component{<Any}
- uuid::String
- dim::Pair{Int64, Int64}
- margin::Pair{Int64, Int64}
"""
abstract type AbstractContext <: Toolips.Modifier end

function compose(name::String, cons::AbstractContext ...)
    newdiv = div(name)
    newdiv[:children] = Vector{Servable}([begin 
    style!(con.window, "display" => "inline-block")
    con.window::Component{<:Any} end for con in cons])
    newdiv::Component{:div}
end

function vcat(comp::Component{:div}, cons::AbstractContext ...)
    push!(comp, br())
    [begin 
    style!(con.window, "display" => "inline-block")
    push!(comp[:children], con.window)
    end for con in cons]
    comp
end

function hcat(comp::Component{:div}, cons::AbstractContext ...)
    [begin 
    style!(con.window, "display" => "inline-block")
    push!(comp[:children], con.window)
    end for con in cons]
    comp
end

push!(comp::Component{:div}, cons::AbstractContext ...) = hcat(comp, cons ...)

"""
### Context <: AbstractContext
- window::Component{:svg}
- uuid::String
- dim::Int64{Int64, Int64}
- margin::Pair{Int64, Int64}

The `Context` can be used with the `draw!` method in order to create and
draw SVG layers in with scaling functions.
##### example
```
using Contexts

con = Context()
line!(con, [5, 1, 2], [7, 34, 5], "stroke" => "red", "stroke-width" => "10")
display(con)
```
------------------
##### constructors
- Context(::Component{:svg}, margin::Pair{Int64, Int64})
- Context(width::Int64 = 1280, height::Int64 = 720, margin::Pair{Int64, Int64} = 0 => 0)
    """
mutable struct Context <: AbstractContext
    window::Component{:svg}
    uuid::String
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Context(wind::Component{:svg}, margin::Pair{Int64, Int64}) = begin
        new(wind, randstring(), wind[:width] => wind[:height],
            margin)::Context
    end
    Context(width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0) = begin
        window::Component{:svg} = svg("window", width = width,
        height = height)
        Context(window, margin)::Context
    end
end

write!(c::Toolips.AbstractConnection, con::AbstractContext) = write!(c, con.window)

function context(f::Function, width::Int64 = 1280, height::Int64= 720, margin::Pair{Int64, Int64} = 0 => 0)
    con = Context(width, height, margin)
    f(con)
    con::Context
end

function merge!(c::AbstractContext, c2::AbstractContext)
    c.window[:children] = vcat(c.window[:children], c2.window[:children])
end

function context(f::Function, con::Context, width::Int64 = 1280, height::Int64= 720, margin::Pair{Int64, Int64} = 1 => 1)
    con = Context(con.windowwidth. height, margin)
    f(con)
    con::Context
end

function open_layer!(f::Function, con::AbstractContext, layer::String)
    [f(e => comp) for (e, comp) in enumerate(con[layer][:children])]
    nothing
end

function delete_layer!(con::Context, layer::String)
    layerpos = findfirst(comp -> comp.name == layer, con.window[:children])
    deleteat!(con.window[:children], layerpos)
    layers(con)
end

function move_layer!(con::AbstractContext, layer::String, to::Int64)
    layerpos = findfirst(comp -> comp.name == layer, con.window[:children])
    layercomp::Toolips.AbstractComponent = con.window[:children][layer]
    deleteat!(con.window[:children], layerpos)
    insert!(con.window[:children], to, layercomp)
    layers(con)
end


function line!(con::AbstractContext, first::Pair{<:Number, <:Number},
    second::Pair{<:Number, <:Number}, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    ln = ToolipsSVG.line(randstring(), x1 = first[1], y1 = first[2],
    x2 = second[1], y2 = second[2])
    style!(ln, styles ...)
    draw!(con, [ln])
end

function text!(con::AbstractContext, x::Int64, y::Int64, text::String, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "black", "font-size" => 13pt)
    end
    t = ToolipsSVG.text(randstring(), x = x, y = y, text = text)
    style!(t, styles ...)
    draw!(con, [t])
end

function star(name::String, p::Pair{String, <:Any} ...; x = 0::Int64, y = 0::Int64, points::Int64 = 5, 
    outer_radius::Int64 = 100, inner_radius::Int64 = 200, angle::Number = pi / points, args ...)
    spoints = star_points(x, y, points, outer_radius, inner_radius, angle)
    comp = Component(name, "star", "points" => "'$spoints'", p ..., args ...)
    comp.tag = "polygon"
    push!(comp.properties, :x => x, :y => y, :r => outer_radius, :angle => angle, 
    :np => points)
    comp::Component{:star}
end

function star_points(x::Int64, y::Int64, points::Int64, outer_radius::Int64, inner_radius::Int64, 
    angle::Number)
    step = pi / points
    join([begin
        r = e%2 == 0 ? inner_radius : outer_radius
        posx = x + r * cos(i)
        posy = y + r * sin(i)
        "$posx $posy"
    end for (e, i) in enumerate(range(0, step * (points * 2), step = step))], ",")::String
end

function shape_points(x::Int64, y::Int64, r::Int64, sides::Int64, angle::Number)
    join([begin
        posx = r + r * sin(i * angle)
        posy = y + r * cos(i * angle)
        "$posx $posy"
    end for i in 1:sides], ",")::String
end

function shape(name::String, p::Pair{String, <:Any} ...; x::Int64 = 0, y::Int64 = 0, 
    sides::Int64 = 3, r::Int64 = 100, angle::Number = 2 * pi / sides, args ...)
    points = shape_points(x, y, r, sides, angle)
    comp = Component(name, "shape", "points" => "'$points'", p ..., args ...)
    comp.tag = "polygon"
    push!(comp.properties, :x => x, :y => y, :r => r, :sides => sides, :angle => angle)
    comp::Component{:shape}
end

struct GattinoShape{T <: Any} end

shape(comp::Component{<:Any}) = GattinoShape{typeof(comp).parameters[1]}()

reshape(comp::Component{<:Any}, into::Symbol; args ...) = reshape(comp, GattinoShape{into}(); args ...)

function reshape(shape::Component{:circle}, into::GattinoShape{:star}; outer_radius::Int64 = 5, inner_radius::Int64 = 3,
    points::Int64 = 5, args ...)
    s = ToolipsSVG.position(shape)
    star(shape.name, x = s[1], y = s[2], outer_radius = outer_radius, inner_radius = inner_radius, points = points)::Component{:star}
end

function reshape(comp::Component{:circle}, into::GattinoShape{:shape}; sides::Int64 = 3, r::Int64 = 5, angle::Number = 2 * pi / sides, args ...)
    s = ToolipsSVG.position(comp)
    shape(comp.name, x = s[1], y = s[2], sides = sides, r = r, angle = angle)::Component{:shape}
end

function size(comp::Component{:star})
    (comp[:r], comp[:r])
end

function size(comp::Component{:shape})
    (comp[:r], comp[:r])
end

set!(ecomp::Pair{Int64, <:Toolips.Servable}, prop::Symbol, value::Any) = ecomp[2][prop] = value

function set!(ecomp::Pair{Int64, <:Toolips.Servable}, prop::Symbol, vec::Vector{<:Number}; max::Int64 = 10)
    maxval::Number = maximum(vec)
    ecomp[2][prop] = Int64(round(vec[ecomp[1]] / maxval * max))
end

function style!(ecomp::Pair{Int64, <:Toolips.AbstractComponent}, vec::Vector{<:Number}, stylep::Pair{String, Int64} ...)
    maxval::Number = maximum(vec)
    style!(ecomp[2], [p[1] => string(Int64(round(vec[ecomp[1]] / maxval * p[2]))) for p in stylep] ...)
end

function style!(ecomp::Pair{Int64, <:Toolips.AbstractComponent}, key::String, vec::Vector{String})
    style!(ecomp[2], key => vec[ecomp[1]])
end

function set_gradient!(ecomp::Pair{Int64, <:Toolips.Servable}, vec::Vector{<:Number}, colors::Vector{String} = ["#DC1C13", "#EA4C46", "#F07470", "#F1959B", "#F6BDC0"])
    maxval::Number = maximum(vec)
    divisions = length(colors)
    div_amount = Int64(round(floor(maxval / divisions)))
    laststep = minimum(vec)
    for color in colors
        if vec[ecomp[1]] in laststep:div_amount
            style!(ecomp[2], "fill" => color)
            break
        end
        laststep, div_amount = div_amount, div_amount + div_amount
    end
end

function show(io::IO, con::AbstractContext)
    display(MIME"text/html"(), con.window)
end

function show(io::Base.TTY, con::AbstractContext)
    println(io, "Context ($(con.dim[1]) x $(con.dim[2]))")
end

getindex(con::AbstractContext, str::String) = con.window[:children][str]

layers(con::AbstractContext) = [e => comp.name for (e, comp) in enumerate(con.window[:children])]

function draw!(c::AbstractContext, comps::Vector{<:Servable})
    current_len::Int64 = length(c.window[:children])
    comp_len::Int64 = length(comps)
    c.window[:children] = Vector{Servable}(vcat(c.window[:children], comps))
    nothing
end

function style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)
    [style!(c, spairs ...) for c in con.window[:children][s][:children]]
    nothing
end
#==TODO
I need some sort of function that will be able to style elements based on their 
    color, radius, whatever.
function style!(con::AbstractContext, s::String, x::Vector{String})

end
==#
function style!(con::AbstractContext, spairs::Pair{String, String} ...)
    style!(con.window, spairs ...)
    nothing
end

mutable struct Group <: AbstractContext
    window::Component{:g}
    uuid::String
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Group(name::String = randstring(), width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0) = begin
        window::Component{:g} = ToolipsSVG.g("$name", width = width, height = height)
        new(window, name, width => height, margin)
    end
end

function group(f::Function, c::AbstractContext, w::Int64 = c.dim[1],
    h::Int64 = c.dim[2], margin::Pair{Int64, Int64} = c.margin)
    gr = Group("n", w, h, margin)
    f(gr)
    draw!(c, Vector{Servable}([child for child in gr.window[:children]]))
end

function group!(f::Function, c::AbstractContext, name::String, w::Int64 = c.dim[1],
    h::Int64 = c.dim[2], margin::Pair{Int64, Int64} = c.margin)
    gr = Group(name, w, h, margin)
    f(gr)
    draw!(c, Vector{Servable}([gr.window]))
end

function animate!(con::AbstractContext, layer::String, animation::Animation)
    style = Style(".$(animation.name)-style")
    animate!(style, animation)
    [comp[:class] = style.name[2:length(style.name)] for comp in con.window[:children][layer][:children]]
    n = findfirst(s -> s.name == style.name, con.window.extras)
    if isnothing(n)
        push!(con.window.extras, style, animation)
    end
end
