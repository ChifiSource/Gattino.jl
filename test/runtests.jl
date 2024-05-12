df = Dict("A" => [5, 10, 15, 20], "B" => [1, 2, 3, 4], "C" => [1, 2, 3, 4])

using Test
using Gattino
@testset "gattino plots" verbose = true begin
    @testset "high-level plotting" verbose = true begin
        @testset "hist" begin
            ran = false
            h = nothing
            try
                h = hist("A", "B", df)
                hist(df["A"], df["B"], ymin = 0, ymax = 50)
                hist(["1", "2", "3", "4"], df["B"], ymin = 0, ymax = 50)
                ran = true
            catch e
                throw(e)
            end
            @test ran == true
            lays = [p[2] for p in layers(h)]
            @test "bars" in lays
            @test "axes" in lays
        end
        @testset "scatter" begin
            ran = false
            h = nothing
            try
                scatter("A", "B", df)
                h = scatter(df["A"], df["B"], ymin = 0, ymax = 50, title = "sample")
                ran = true
            catch

            end
            @test ran
            lays = [p[2] for p in layers(h)]
            @test "points" in lays
            @test length(h.window[:children]["points"][:children]) == length(df["A"])
            @test "axes" in lays
        end
        @testset "line" begin
            ran = false
            h = nothing
            try
                h = line("A", "B", df)
                line(df["A"], df["B"], ymin = 0, ymax = 50, title = "sample")
                line(["hi", "hello"], df["A"][1:2])
                ran = true
            catch

            end
            @test ran
            lays = [p[2] for p in layers(h)]
            @test "C" in lays
            @test "axes" in lays
            @test "grid" in lays
        end
    end
    @testset "colors" begin
        randco = Gattino.randcolor()
        @test randco[1] == "#"
        @test length(randco) == 7
        grad = make_gradient((255, 0, 0), 10, 5, 5, 0)
        @test length(grad) == 10
        @test grad[2] == "rgb(260, 5, 0)"
    end
    @testset "contexts" verbose = true begin
        @testset "base contexts" begin
            newcon = context()
            @test typeof(newcon) <: Gattino.AbstractContext
            newcon = context(100, 100, 5 => 5)
            @test con.dim == 100 => 100
            newcon = context(100, 100) do con::Context
                points!(con, [5, 10, 15], [5, 10, 15])
                group!(con, "sample") do g::Group
                    text!(g, 5, 10, "hello!")
                end
            end
            @test length(newcon.window[:children]) == 2
            @test length(newcon.window["sample"][:children]) == 1
        end
        con = context()
        @testset "groups" begin
            g = group(con, 100, 50, 50 => 5) do g
                group!(g, "text") do g2::Group
                    text!(g, 2, 5, "hello")
                end
            end
            @test string(con.window[:children]["text"][1][x]) == string(50 + 2 + 5)
            @test length(g.window[:children]) == 1
            @test length(con.window[:children]) == 1
        end
        @testset "cat layouts" begin
            testcat = hcat(vcat(con, con), vcat(con, con))
            @test typeof(testcat) == Component{:div}
            f = findfirst(comp -> typeof(comp) == Component{:br}, testcat[:children])
            @test ~(isnothing(f))
            @test f == 3
            @test length(testcat) == 5
        end
        @testset "layers" begin
            @test "text" in [p[2] for p in layers(con)]
            rename_layer!(con, "text", "label")
            @test ~("text" in [p[2] for p in layers(con)])
            @test "label" in [p[2] for p in layers(con)]
            con2 = context(500, 500) do cont::Context
                line!(con2, 5 => 6, 4 => 5)
            end
            @test length(layers(con2)) == 1
            merge!(con, con2)
            @test length(con.window[:children]) == 2
            delete_layer!(con, "label")
            @test ~("label" in [p[2] for p in layers(con)])
            @test length(con.window[:children]) == 1
            newcon = scatter([5, 10, 78], [20, 30, 10])
            @test length(newcon[:children]["points"][:children]) == 3
            set_shape!(newcon, "points", :star)
            @test typeof(newcon.window[:children]["points"][:children][1]) == Component{:star}
            style!(newcon, "grid", "stroke" => "orange")
            @test contains(newcon.window[:children]["grid"][1]["style"], "stroke:orange;")
            open_layer(newcon, "points") do ecomp
                set!(ecomp, :r, 10)
                
            end
            @test string(newcon[:children]["points"][1]["r"]) == "10"
        end
        @testset "compression" begin
            size = sizeof(con)
            compress!(con)
            newsize = sizeof(con)
            @test length(con.window[:children]) == 0
            @test newsize < size
        end
    end
    @testset "context plotting" verbose = true begin
        
    end
end