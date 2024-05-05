#== Contexts.jl
- abstract contexts
- compositions
- base contexts
- layers and grouping
- open layer
- context drawing
==#
"""
### abstract type AbstractContext <: ToolipsSVG.ToolipsServables.Modifier
AbstractContexts are `Modifiers` that can be used to draw inside of a given frame.
These contexts can be drawn on using the `draw!` method and keep track of
different elements inside of the Context.
##### Consistencies
- window::Component{<Any}
- dim
- margin
"""
abstract type AbstractContext <: ToolipsSVG.ToolipsServables.Modifier end

"""
####### compositions
Layouts in `Gattino` can be created using two techniques; scaling and composition. Using scaling 
will mean that all of the visualizations in our layout are on the same `Context`. Using compositions 
will mean that our visualizations will sit on seperate contexts beside one another. Scaling is done using 
margins and dimensions of contexts, whereas compositions are done using `compose`, `vcat`, and `hcat`
"""
function compose end

"""
```julia
compose(name::String, cons::AbstractContext ...) -> ::Component{:div}
```
---
Composes `cons` into a new `Component{:div}` called `name`. Composing is done 
using either this method, or `vcat`/`hcat`.
```example
using Gattino

firstcon = context(50, 50) do con::Context
    Gattino.text!(con, 25, 25, "hello", "fill" => "black")
end

secondcon = context(50, 50) do con::Context
    Gattino.text!(con, 25, 25, "world", "fill" => "black")
end

finalvis = compose("myframe", firstcon, secondcon)
```
"""
function compose(name::String, cons::AbstractContext ...)
    newdiv = div(name)
    newdiv[:children] = Vector{Servable}([begin 
    style!(con.window, "display" => "inline-block")
    con.window::Component{<:Any} end for con in cons])
    newdiv::Component{:div}
end

"""
```julia
vcat(comp::AbstractContext, cons::AbstractContext ...) -> ::Component{:div}
```
---
Creates a new `:div` for `comp` and concatenates all provided `cons` vertically.
```example

```
"""
function vcat(comp::AbstractContext, cons::AbstractContext ...)
    newdiv = div(randstring(3))
    style!(comp.window, "display" => "inline-block")
    push!(newdiv, comp.window)
    push!(newdiv, br())
    [begin
        style!(co.window, "display" => "inline-block")
        push!(newdiv, co.window)
    end for co in cons]
    newdiv
end

"""
```julia
hcat(comp::AbstractContext, cons::AbstractContext ...) -> ::Component{:div}
```
---
Creates a new `:div` for `comp` and concatenates all provided `cons` horizontally.
```example

```
"""
function hcat(comp::AbstractContext, cons::AbstractContext ...)
    newdiv = div(randstring(3))
    style!(comp.window, "display" => "inline-block")
    push!(newdiv, comp.window)
    [begin
        style!(co.window, "display" => "inline-block")
        push!(newdiv, co.window)
    end for co in cons]
    newdiv
end

"""
```julia
vcat(comp::Component{:div}, cons::AbstractContext ...) -> ::Component{:div}
```
---
Concatenates `cons` to the composition `comp` vertically.
```example

```
"""
function vcat(comp::Component{:div}, cons::AbstractContext ...)
    push!(comp, br())
    [begin 
    style!(con.window, "display" => "inline-block")
    push!(comp[:children], con.window)
    end for con in cons]
    comp
end

"""
```julia
vcat(comp::Component{:div}, cons::AbstractContext ...) -> ::Component{:div}
```
---
Concatenates `cons` to the composition `comp` horizontally.
```example

```
"""
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

The `Context` can be used with `Gattino` methods in order to create and
draw introspectable SVG layers with scaling functions. This constructor is 
typically not called directly, instead use the `context` function. `?context` 
provides a lot more information on contexts and context grouping.
##### example
```
using Gattino

# how you should probably use contexts
mycontext = context(500, 500) do con::Context
    Gattino.line!(con, [1, 2, 3], [1, 8, 4], "stroke" => "red", "stroke-width" => 2px)
end

# you (can) still do this, of course.
con = Context()
Gattino.line!(con, [5, 1, 2], [7, 34, 5], "stroke" => "red", "stroke-width" => "10")
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

string(con::AbstractContext) = string(con.window)

"""
##### contexts
```julia
context -> ::AbstractContext
```
A `Context` is a wrapper for a `Component{:svg}` which can be used with mutating methods to 
draw scaled shapes onto an SVG window. Contexts are generally created through methods of this 
function, which typically take a `Function` and dimensions for the `context`.

To adjust the scaling of a `Context` from a `Context`, use `group`.
- `group`

Gattino mutating methods (`Gattino._`) may be used from context components or context plotting, 
(`?Gattino.context_components`, `?Gattino.context_plotting`) , or `Toolips` components may be drawn from a `Vector{Servable}` with 
`draw!`.
- `draw!`
- `Gattino.context_components`
- `Gattino.context_plotting`
####### layers
Contexts have layers, which can be mutated using a mixture `Toolips` syntax, such as 
`style!`, and `Gattino` layer editing functions. These include...
- `open_layer!`
- `delete_layer!`
- `rename_layer!`
- `move_layer!`
- `reshape(con::AbstractContext, layer::String, into::Symbol; args ...)`
- `style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)`
- `style!(con::AbstractContext, spairs::Pair{String, String} ...)`
- `animate!(con::AbstractContext, layer::String, anim::ToolipsSVG.ToolipsServables.Animation)`

New layers may be created using grouping.
- `group!`

####### methods
"""
function context end

"""
```julia
context(f::Function, width::Int64 = 500, height::Int64 = 720, margin::Pair{Int64, Int64} = 0 => 0) -> ::Context
```
This dispatch of `context` is used to create a 2D `Context`. Margins are provided as a `Pair{Int64, Int64}`, these are the left and top margins 
respectively. 
```example
con = context(500, 500) do con::Context
    text!(con, 250, 250, "hello world!")
end
```
Using a combination of `group` and `group!`, we can build layers with specified scaling.
For example, the following `Context` draws a shape starting starting at 250px from the left of this 500x500 frame, still consuming 
the entire height. For proper scaling, I also made the width 250 less. This will make a scaled window inside of the `Context` that is offset by 
250px and 250px wide, whereas our window is not offset at all and has a full width of 500px.
```example
con = context(500, 500) do con::Context
    Gattino.text!(con, 250, 250, "hello world!")
    group(con, 250, 500, 250 => 0) do pointarea
        Gattino.points!(pointarea, [1, 2, 8, 4, 3, 4], 1, 2, 6, 7, 4, 5)
    end
end
```
"""
function context(f::Function, width::Int64 = 500, height::Int64= 720, margin::Pair{Int64, Int64} = 0 => 0)
    con = Context(width, height, margin)
    f(con)
    con::Context
end

"""
```julia
context(f::Function, con::Context, width::Int64 = 1280, height::Int64= 720, margin::Pair{Int64, Int64} = 1 => 1) -> ::Context
```
This `context` method is used to create a new `Context` of a different size using the window of a different `Context`.
```example

```
"""
function context(f::Function, con::Context, width::Int64 = 1280, height::Int64= 720, margin::Pair{Int64, Int64} = 1 => 1)
    con = Context(con.window, width, height, margin)
    f(con)
    con::Context
end

"""
```julia
layers(con::AbstractContext) -> ::Vector{Pair{Int64, String}}
```
Shows layers of a `Context`.
```example
using Gattino

example = hist(["hello"], [500])

layers(example)
```
"""
layers(con::AbstractContext) = [e => comp.name for (e, comp) in enumerate(con.window[:children])]

getindex(con::AbstractContext, str::String) = con.window[:children][str]

function draw!(c::AbstractContext, comps::Vector{<:ToolipsSVG.Servable})
    current_len::Int64 = length(c.window[:children])
    comp_len::Int64 = length(comps)
    c.window[:children] = vcat(c.window[:children], comps)
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

function style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)
    layer = con.window[:children][s]
    if length(layer[:children]) > 0
        [style!(c, spairs ...) for c in layer[:children]]
        return(nothing)
    end
    style!(layer, spairs ...)
    nothing::Nothing
end

function style!(con::AbstractContext, spairs::Pair{String, String} ...)
    style!(con.window, spairs ...)
    nothing
end

function animate!(con::AbstractContext, layer::String, animation::ToolipsSVG.KeyFrames)
    style = Style(".$(animation.name)-style")
    animate!(style, animation)
    [comp[:class] = style.name[2:length(style.name)] for comp in con.window[:children][layer][:children]]
    n = findfirst(s -> s.name == style.name, con.window.extras)
    if isnothing(n)
        push!(con.window.extras, style, animation)
    end
end

"""
```julia
merge!(c::AbstractContext, c2::AbstractContext) -> ::Nothing
```

```example

```
"""
function merge!(c::AbstractContext, c2::AbstractContext)
    c.window[:children] = vcat(c.window[:children], c2.window[:children])
end

"""
```julia
delete_layer!(con::Context, layer::String) -> ::Nothing
```

```example

```
"""
function delete_layer!(con::Context, layer::String)
    layerpos = findfirst(comp -> comp.name == layer, con.window[:children])
    deleteat!(con.window[:children], layerpos)
    layers(con)
end

"""
```julia
rename_layer!(con::Context, layer::String, to::String) -> ::Nothing
```

```example

```
"""
rename_layer!(con::Context, layer::String, to::String) = begin
    l = con.window[:children][layer]
    l.name = to
    nothing
end


"""
```julia
move_layer!(con::Context, layer::String, to::Int64) -> ::Nothing
```

```example

```
"""
function move_layer!(con::AbstractContext, layer::String, to::Int64)
    layerpos = findfirst(comp -> comp.name == layer, con.window[:children])
    layercomp::ToolipsSVG.AbstractComponent = con.window[:children][layer]
    deleteat!(con.window[:children], layerpos)
    insert!(con.window[:children], to, layercomp)
    layers(con)
end

"""
```julia
open_layer!(f::Function, con::AbstractContext, layer::String) -> ::Nothing
```

```example

```
"""
function open_layer!(f::Function, con::AbstractContext, layer::String)
    [begin
        f(e => comp)
        con[layer][:children][e] = comp 
    end for (e, comp) in enumerate(con[layer][:children])]
    nothing::Nothing
end

"""
```julia
set!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.Servable}, args ...; keyargs ...)
```
`set!` is used in tandem with `open_layer!` to set the properties of elements -- usually according
to data.
```julia
# sets every component's property statically:
set!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.Servable}, prop::Symbol, value::Any)
# scales the value based on `vec`, using `max` for values that are `100`-percent of the maximum of `vec`.
set!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.Servable}, prop::Symbol, vec::Vector{<:Number}; max::Int64 = 10)
# sets value to 
set!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.Servable}, prop::Symbol, vec::Vector{<:AbstractString})
```
The same dispatches are also available for `style!`.
- See also: `style!`, `set_gradient!`, `open_layer!`, `set_shape!`, `Context`
```example

```
"""
function set! end

set!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.Servable}, prop::Symbol, value::Any) = ecomp[2][prop] = value

function set!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.Servable}, prop::Symbol, vec::Vector{<:Number}; max::Int64 = 10)
    maxval::Number = maximum(vec)
    ecomp[2][prop] = Int64(round(vec[ecomp[1]] / maxval * max))
end

function set!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.Servable}, prop::Symbol, vec::Vector{<:AbstractString})
    ecomp[2][prop] = vec[ecomp[1]]
end

function set_gradient!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.Servable}, vec::Vector{<:Number}, colors::Vector{String} = ["#DC1C13", "#EA4C46", "#F07470", "#F1959B", "#F6BDC0"])
    maxval::Number = maximum(vec)
    divisions = length(colors)
    div_amount = floor(maxval / divisions)
    laststep = minimum(vec)
    for color in colors
        if vec[ecomp[1]] in laststep:div_amount
            style!(ecomp[2], "fill" => color)
            break
        end
        laststep, div_amount = div_amount, div_amount + div_amount
    end
end

function style!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.AbstractComponent}, vec::Vector{<:Number}, stylep::Pair{String, Int64} ...)
    maxval::Number = maximum(vec)
    style!(ecomp[2], [p[1] => string(Int64(round(vec[ecomp[1]] / maxval * p[2]))) for p in stylep] ...)
end

function style!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.AbstractComponent}, key::String, vec::Vector{String})
    style!(ecomp[2], key => vec[ecomp[1]])
end

function style!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.AbstractComponent}, p::Pair{String, String} ...)
    style!(ecomp[2], p ...)
end

function set_shape!(con::AbstractContext, layer::String, into::Symbol; args ...)
    shape = SVGShape{into}
    con.window[:children][layer][:children] = [set_shape(comp, shape, args ...) for comp in con.window[:children][layer][:children]]
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

function show(io::IO, con::AbstractContext)
    display(MIME"text/html"(), con.window)
end

function show(io::Base.TTY, con::AbstractContext)
    println(io, "Context ($(con.dim[1]) x $(con.dim[2]))")
end
