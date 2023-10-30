<div align="center"><img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/gattino.png" width = 250 />
  <h4>gattino</h4>
</div>
<div align="left">

Gattino is Toolips-based plotting for Julia. This project's base package is still in early development, but gattino plans to feature
- An extension **ecosystem**.
- Introspectable, mutable **high-level plotting**.
- **Animated** visualizations.
- **Interactive** visualizations.
- **easy** styling syntax
- In-ecosystem **dashboard toolkits**.
- In-server **deployment**.
- **Scaling** graphics.

There is currently a lot underway when it comes to [Chifi](https://github.com/ChifiSource/) packages, so this package is currently a **work in progress**.
##### map
- [getting started](#getting-started)
   - [adding gattino](#adding-gattino)
   - [Components](#components)
   - [visualizations](#creating-visualizations)
     - [high-level methods](#high-level-methods)
     - [editing visualizations](#editing-visualizations)
     - [annotating visualizations](#annotating-visualizations)
     - [layouts](#layouts)
     - [animating visualizations](#animating-visualization)
     - [creating visualizations](#creating-visualizations)
     - [controlling visualizations](#controlling-visualizations)
   - [creating dashboards](#creating-dashboards)
- [Contexts](#contexts)
    - [Groups](#groups)
- [context plotting](#context-plotting)
    - [lines](#plotting-lines)
    - [shapes](#plotting-shapes)
    - [other](#plotting-other-stuff)
- [examples](#examples)
- [adding more](#adding-more)
## getting started
##### adding gattino
Before `Gattino` is merged to the Julia `General` `Pkg` registry, `Gattino will need to be added by URL.
```julia
using Pkg; Pkg.add(url = "https://github.com/ChifiSource/Gattino.jl")
using Gattino
```
If you would like to use the `Unstable` version of Gattino, which will have more features but be less stable, set the `rev` key-word argument to `Unstable`.
```julia
using Pkg; Pkg.add(url = "https://github.com/ChifiSource/Gattino.jl", rev = "Unstable")
using Gattino
```
##### visualizations
Graphics in `Gattino` are scaled using the `Context` and `Group` types. A `Context` represents a window, whereas a `Group` represents an area in that window. To create a context, we use the `context` method.
- `context(f::Function, width::Int64 = 1280, height::Int64= 720, margin::Pair{Int64, Int64} = 0 => 0)`
```julia
mycontext = context(500, 500) do con::Context

end
```
This `Context` can now be used with [context plotting](#context-plotting) methods. There are two different types of `group` which we can use on our project,
` `group!` is the mutating group -- this will add anything drawn to the group to the `Context`.
- `group` is non-mutating group -- anything we draw will not be drawn onto the window.

These two forms of group are used in tandem to organize the layers of our `Context`. `group` is used to define new `AbstractContext` dimensions without adding a layer, whereas `group!` will add a new layer in those dimensions. For example.
```julia
mycon = context(500, 500) do con::Context
    group(con, 500, 250) do gridbox::Group
        group!(gridbox, "grid") do g::Group
            Gattino.grid!(g, 4)
        end
    end
    group(con, 500, 250, 0 => 250) do otherbox::Group
        group!(otherbox, "grid2") do g::Group
            Gattino.grid!(g, 4, "stroke" => "pink")
            
        end
    end
    Gattino.text!(con, 230, 250, "hello!")
end
```
```julia
layers(mycon)

3-element Vector{Pair{Int64, String}}:
 1 => "grid"
 2 => "grid2"
 3 => "la81WFbV"
```
###### high-level methods
While `Gattino` plots are completely composable and can be made by composing [context plotting](#context-plotting) elements together, the module also comes with some high-level functions which may be used to produce standard visualizations we are likely familiar with.
```julia
scatter(x::Vector{<:Number}, y::Vector{<:Number}, width::Int64 = 500,
height::Int64 = 500, margin::Pair{Int64, Int64} = 0 => 0; divisions::Int64 = 4,
    title::String = "", args ...)

line(x::Vector{<:Number}, y::Vector{<:Number}, width::Int64 = 500,
height::Int64 = 500, margin::Pair{Int64, Int64} = 0 => 0; divisions::Int64 = 4,
    title::String = "", args ...)

line(x::Vector{<:Any}, y::Vector{<:Number}, width::Int64 = 500,
height::Int64 = 500, margin::Pair{Int64, Int64} = 0 => 0;
    divisions::Int64 = length(x), title::String = "", args ...)

hist(x::Vector{<:Any}, y::Vector{<:Number}, width::Int64 = 500, height::Int64 = 500,
    margin::Pair{Int64, Int64} = 0 => 0; divisions::Int64 = length(x))
```
These methods are used to create a minimalistic visualization which can be further mutated with other `Gattino` methods.
###### editing-visualizations
Here are some common methods for this purpose:
```julia
style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)

getindex(con::AbstractContext, str::String)

layers(con::AbstractContext)
```
In each of these examples, `con` of type **`AbstractContext`** would be our `Context` returned from any of those methods.
Lastly, these high-level visualization methods simply compose a plot using the methods from `context_plotting.jl`. We can add new layers to our 
###### annotating visualizations
###### layouts
###### animating visualizations
###### creating visualizations
###### controlling visualizations
##### creating dashboards
### contexts
#### groups

### context plotting
#### plotting lines
#### plotting shapes
#### plotting other stuff

### examples
