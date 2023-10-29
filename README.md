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
### getting started
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

###### high-level methods
When using Gattino, there is a pretty good chance you are going to be using the high-level methods which compose several `context_plotting` elements. Here are the high-level dispatches for creating a visualization:
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
