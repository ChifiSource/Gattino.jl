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
```julia
vcat(comp::AbstractContext, cons::AbstractContext ...) -> ::Component{:div}
```
---
Creates a new `:div` for `comp` and concatenates all provided `cons` vertically.
```example

```
"""
function vcat(comp::AbstractContext, cons::AbstractContext ...)
    newdiv = div(gen_ref(3))
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
    newdiv = div(gen_ref(3))
    style!(comp.window, "display" => "inline-block")
    push!(newdiv, comp.window)
    [begin
        style!(co.window, "display" => "inline-block")
        push!(newdiv, co.window)
    end for co in cons]
    newdiv::Component{:div}
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
    comp::Component{:div}
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

function vcat(comp::Component{:div}, cons::Component{:div} ...)
    push!(comp, br())
    [begin 
        style!(con, "display" => "inline-block")
        push!(comp[:children], con)
    end for con in cons]
    comp::Component{:div}
end


function hcat(comp::Component{:div}, cons::Component{:div} ...)
    push!(comp, br())
    [begin 
        style!(con, "display" => "inline-block")
        push!(comp[:children], con)
    end for con in cons]
    comp::Component{:div}
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
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Context(wind::Component{:svg}, margin::Pair{Int64, Int64}) = begin
        new(wind, wind[:width] => wind[:height],
            margin)::Context
    end
    Context(width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0) = begin
        window::Component{:svg} = svg(gen_ref(5), width = width,
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
    con::Context = Context(width, height, margin)
    f(con)
    con::Context
end

context(width::Int64 = 500, height::Int64= 720, margin::Pair{Int64, Int64} = 0 => 0) = begin
    context(c::Context -> c::Context, width, height, margin)
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
    con::Context = Context(con.window, width, height, margin)
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

layers(con::AbstractContext, in::String) = [e => comp.name for (e, comp) in enumerate(con.window[:children][in][:children])]

getindex(con::AbstractContext, str::String) = con.window[:children][str]

"""
```julia
draw!(c::AbstractContext, comps::Vector{<:ToolipsSVG.Servable}) -> ::Nothing
```
Draws the elements in `comps` onto the window of `c`.
```example

```
"""
function draw!(c::AbstractContext, comps::Vector{<:ToolipsSVG.Servable})
    c.window[:children] = vcat(c.window[:children], comps)
    nothing::Nothing
end

"""
### Group <: AbstractContext
- window::Component{:g}
- uuid::String
- dim::Int64{Int64, Int64}
- margin::Pair{Int64, Int64}

A `Group` is a `Context` which is held beneath another context. These 
are used to create scaling with `group` and create layers with `group!`.
##### example
```
using Gattino
x = ["purple", "pink", "orange", "blue", "red", "white"]
y = [20, 40, 2, 3, 25, 49]

mycon = context(500, 500) do con::Context
    group(con, 250, 250) do firstvis::Group
        group!(firstvis, "axes") do g::Group
            Gattino.axes!(g)
        end
        group!(firstvis, "grid") do g::Group
            Gattino.grid!(g, 4)
        end
        group!(firstvis, "bars") do g::Group
            Gattino.bars!(g, x, y, "stroke-width" => 1px, "stroke" => "darkgray")
            [style!(comp, "fill" => color) for (comp, color) in zip(g.window[:children], x)]
        end
        group!(firstvis, "labels") do g::Group
            Gattino.barlabels!(g, x, "stroke-width" => 0px, "font-size" => 11pt)
        end
    end
    group(con, 250, 250, 250 => 0) do secondvis::Group
        group!(secondvis, "grid2") do g::Group
            Gattino.grid!(g, 4, "stroke" => "pink")
        end
        group!(secondvis, "line") do g::Group
            Gattino.line!(g, x, y)
        end
        group!(secondvis, "labels") do g::Group
            Gattino.gridlabels!(g, x, y, 4)
        end
    end
    group(con, 500, 250, 0 => 250) do bottomvis::Group
        group!(bottomvis, "grid3") do g::Group
            Gattino.scatter_plot!(g, [1, 2, 3], [1, 2, 3])
        end
    end
end
```
------------------
##### constructors
```julia
Group(name::String = gen_ref(5), width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0)
```
"""
mutable struct Group <: AbstractContext
    window::Component{:g}
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Group(name::String = gen_ref(5), width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0) = begin
        window::Component{:g} = ToolipsSVG.g(name, width = width, height = height)
        new(window, width => height, margin)
    end
end

"""
```julia
group(f::Function, c::AbstractContext, w::Int64 = c.dim[1],
    h::Int64 = c.dim[2], margin::Pair{Int64, Int64} = c.margin) -> ::Nothing
```
Creates a *scaling group* on `c`, the `Context` (or `Group`). This will *not* create 
a layer, only a scaling window. This creates the `Group` in the same way, but draws its children to 
`c`'s children. For layers, use `group!`
```example

```
"""
function group(f::Function, c::AbstractContext, w::Int64 = c.dim[1],
    h::Int64 = c.dim[2], margin::Pair{Int64, Int64} = c.margin)
    gr::Group = Group("n", w, h, margin)
    f(gr)
    draw!(c, Vector{Servable}([child for child in gr.window[:children]]))
    nothing::Nothing
end

"""
```julia
group!(f::Function, c::AbstractContext, name::String, w::Int64 = c.dim[1],
    h::Int64 = c.dim[2], margin::Pair{Int64, Int64} = c.margin) -> ::Nothing
```
Creates a layer by name `name` on `c`, and scales that layer to the dimensions provided.
```example

```
"""
function group!(f::Function, c::AbstractContext, name::String, w::Int64 = c.dim[1],
    h::Int64 = c.dim[2], margin::Pair{Int64, Int64} = c.margin)
    gr = Group(name, w, h, margin)
    f(gr)
    draw!(c, Vector{Servable}([gr.window]))
end

"""
###### gattino context styling
```julia
style!(con::AbstractContext, args ...) -> ::Nothing
```
`style!` is extended to work with `Gattino` contexts. We can style the window with 
`style!(con::AbstractContext, spairs::Pair{String, String} ...)` and style layers with 
`style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)` just as we would normal 
components.
```julia
style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)
style!(con::AbstractContext, spairs::Pair{String, String} ...)
```
- See also: `animate!(::AbstractContext, ::String, ::ToolipsSVG.KeyFrames)`, `set!`, `Context`, `layers`
```example

```
"""
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
    nothing::Nothing
end


function style!(con::AbstractContext, layer::String, anim::KeyFrames)
    style!(con.window[:children][layer], anim)
end

"""
```julia
style!(con::AbstractContext, layer::String, animation::ToolipsSVG.KeyFrames) -> ::Nothing
```
Animates the layer `layer` with the animation `animation`.
"""
function style!(con::AbstractContext, layer::String, a::ToolipsSVG.ToolipsServables.AbstractAnimation)
    layer::Component{<:Any} = con.window[:children][layer]
    if length(layer[:children]) > 1
        [style!(child, a) for child in layer[:children]]
    end
    style!(layer, a)
    if ~(a.name in con.window[:extras])
        push!(con.window[:extras], a)
    end
end

"""
```julia
merge!(c::AbstractContext, c2::AbstractContext) -> ::Nothing
```
Merges the contents of contexts `c` and `c2` into `c`'s `window`.
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
Deletes the layer `layer` from `con` by name.
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
Renames the layer `layer` to `to` on `con`.
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
Moves the layer up or down, making it more or less visible. `style!` with `z-index` 
can also be used to rearrange the order of elements.
```examove_layer!mple

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
set_shape!(con::AbstractContext, layer::String, into::Symbol; args ...) -> ::Nothing
```
Sets the shape of each element in `layer` to `into`. This uses the `ToolipsSVG.SVGShape` 
interface to reshape components. The available shapes built into this API are...
- `:square`
- `:circle`
- `:polyshape`
- `:rect`
- and `:star`
```example
newscatter = scatter([1, 2, 3], [1, 2, 3])
set_shape!(newscatter, "points", :star)
```
"""
function set_shape!(con::AbstractContext, layer::String, into::Symbol; args ...)
    shape = SVGShape{into}
    con.window[:children][layer][:children] = [set_shape(comp, shape, args ...) for comp in con.window[:children][layer][:children]]
end

"""
```julia
open_layer!(f::Function, con::AbstractContext, layer::String) -> ::Nothing
```
`open_layer` will open `layer` from `con`, providing each `Component` inside of that layer, 
alongside its enumeration, to `f`. With this, functions such as `set!`, `set_gradient!`, 
and additional `style!` dispatches can be used to make changes to entire layers -- with some 
dispatches, these layers are based on data and are able to further represent features.
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

"""
```julia
set_gradient!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.Servable}, 
vec::Vector{<:Number}, colors::Vector{String} = make_gradient((1, 100, 120), 10, 30, 10, -10)) -> ::Nothing
```
`set_gradient!` is used to display new values with a gradient between different colors with `open_layer!`.
```example

```
"""
function set_gradient!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.Servable}, vec::Vector{<:Number}, colors::Vector{String} = make_gradient((1, 100, 120), 10, 30, 10, -10))
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

"""
###### gattino layer styling
```julia
style!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.AbstractComponent}, args ...) -> ::Nothing
```
`style!` has bindings for styling layer data according to data, or otherwise.
components.
```julia
# style the value of `stylep` based on the values of `vec` on the open components.
style!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.AbstractComponent}, vec::Vector{<:Number}, stylep::Pair{String, Int64} ...)
# style each subsequent component with each subsequent element in `vec`
style!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.AbstractComponent}, key::String, vec::Vector{String})
# regular styling:
style!(ecomp::Pair{Int64, <:ToolipsSVG.ToolipsServables.AbstractComponent}, p::Pair{String, String} ...)
```
note that you can also `style!` by layer `name` on a `Context`.
- See also: `animate!(::AbstractContext, ::String, ::ToolipsSVG.KeyFrames)`, `set!`, `Context`, `layers`, `open_layer!`
```example

```
"""
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

function show(io::IO, con::AbstractContext)
    display(MIME"text/html"(), con.window)
end

function show(io::Base.TTY, con::AbstractContext)
    println(io, "Context ($(con.dim[1]) x $(con.dim[2]))")
end

function compress!(con::AbstractContext)
    ToolipsSVG.ToolipsServables.compress!(con.window)::Nothing
end