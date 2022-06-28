module Prrty
using Toolips
import Toolips: Servable, AbstractConnection
using ToolipsSession
using Pkg
include("Components.jl")
function new_project(name::String)
    Toolips.new_webapp(name)
     open("$name/src/$name.jl", "w") do o

     end
     open("$name/dev.jl") do o

     end
     open("$name/prod.jl") do o

     end
     Pkg.activate(name)
     Pkg.add(url = "https://github.com/ChifiSource/Prrty.jl.git")
end
export new_project, DashBoard, plotpane, pane, page, textbox, containertextbox
export numberinput, rangeslider, update!
end # module
