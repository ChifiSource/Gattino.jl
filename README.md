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
- [visualizations](#visualizations)
  - [creating visualizations](#high-level-methods)
  - [layouts](#layouts)
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

###### creating visualizations
While `Gattino` plots are completely composable and can be made by composing [context plotting](#context-plotting) elements together, the module also comes with some high-level functions which may be used to produce standard visualizations we are likely familiar with. These examples currently include `scatter`, `line`, and `hist`.
```julia
scatter(x::Vector, y::Vector, divisions::Int64 = 4, title::String = "")

line(x::Vector, y::Vector, divisions::Int64 = 4, title::String = "")

hist(x::Vector, y::Vector, divisions::Int64 = 4, title::String = "")
```
These methods are used to create a minimalistic visualization which can be further mutated with other `Gattino` methods. In each of these examples,the return type will be an `AbstractContext`. Let's make our first histogram with `Gattino`.
```julia
myhist = hist(["emma", "emmy", "em"], [22, 25, 14], title = "votes for names")
```
The `hist` function is just a passthrough to `hist!`, which is a [context plotting](#context-plotting) function that creates a histogram. Notably, `hist` will create a new `Context` for us and `hist!` expects us to provide an `AbstractContext` as an argument. The `line` and `scatter` equivalence to this is found in `scatter_plot!` and `line_plot!`. That being said, if we want to add a visualization to a `Context` that already exists, we would use these methods, rather than the high-level method. When using `hist!` we will want to add our histogram to an old plot, when using `hist` we will be making a new plot with a new window. Here, I will use the `context` and `group!` functions to compose a scatter with the `scatter_plot!` method.
```julia
myframe = context(500, 500) do con::Context
    group!(con, "scatter", 250, 250) do g::Group
        Gattino.scatter_plot!(g, [1, 2, 3, 4], [1, 2, 3, 4])
    end
end
```
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
###### layouts

###### editing-visualizations
Here are some common methods for this purpose:
```julia
style!(con::AbstractContext, s::String, spairs::Pair{String, String} ...)

getindex(con::AbstractContext, str::String)

layers(con::AbstractContext)
```
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
