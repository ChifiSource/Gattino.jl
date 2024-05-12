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
        @test randco[1] == '#'
        @test length(randco) == 7
        grad = Gattino.make_gradient((255, 0, 0), 10, 5, 5, 0)
        @test length(grad) == 10
        @test grad[1] == "rgb(260,5,0,1.0)"
    end
    @testset "contexts" verbose = true begin
        @testset "base contexts" begin
            newcon = context()
            @test typeof(newcon) <: Gattino.AbstractContext
            newcon = context(100, 100, 5 => 5)
            @test newcon.dim == [100 => 100][1]
            newcon = context(100, 100) do con::Context
                Gattino.points!(con, [5, 10, 15], [5, 10, 15])
                group!(con, "sample") do g::Group
                    Gattino.text!(g, 5, 10, "hello!")
                end
            end
            @test length(newcon.window[:children]) == 4
            @test length(newcon.window[:children]["sample"][:children]) == 1
        end
        con = context()
        @testset "groups" begin
            g = group(con, 100, 50, 50 => 5) do g
                group!(g, "text") do g2::Group
                    Gattino.text!(g2, 2, 5, "hello")
                end
                group!(g, "points") do g2::Group
                    Gattino.points!(g2, [2, 3], [5, 3])
                end
            end
            @test string(con.window[:children]["points"][:children][1]["cx"]) == "50"
            @test length(con.window[:children]) == 2
            @test length(con.window[:children]["text"][:children]) == 1
        end
        @testset "cat layouts" begin
            testcat = hcat(vcat(con, con), vcat(con, con))
            @test typeof(testcat) == Component{:div}
            f = findfirst(comp -> typeof(comp) == Component{:br}, testcat[:children])
            @test ~(isnothing(f))
            @test f == 2
            @test length(testcat[:children]) == 5
        end
        @testset "layers" begin
            @test "text" in [p[2] for p in layers(con)]
            rename_layer!(con, "text", "label")
            @test ~("text" in [p[2] for p in layers(con)])
            @test "label" in [p[2] for p in layers(con)]
            con2 = context(500, 500) do cont::Context
                Gattino.line!(cont, 5 => 6, 4 => 5)
            end
            @test length(layers(con2)) == 1
            Gattino.merge!(con, con2)
            @test length(con.window[:children]) == 3
            delete_layer!(con, "label")
            @test ~("label" in [p[2] for p in layers(con)])
            @test length(con.window[:children]) == 2
            newcon = scatter([5, 10, 78], [20, 30, 10])
            @test length(newcon.window[:children]["points"][:children]) == 3
            set_shape!(newcon, "points", :star)
            @test typeof(newcon.window[:children]["points"][:children][1]) == Component{:star}
            style!(newcon, "grid", "stroke" => "orange")
            @test contains(newcon.window[:children]["grid"][:children][1]["style"], "stroke:orange;")
            open_layer!(newcon, "points") do ecomp
                set!(ecomp, :r, 10)
            end
            @test string(newcon.window[:children]["points"][:children][1]["r"]) == "10"
        end
        @testset "compression" begin
            Gattino.points!(con, randn(500), randn(500))
            size = sizeof(con)
            compress!(con)
            @test length(con.window[:children]) == 0
        end
    end
    @testset "context plotting" verbose = true begin
        newcon = context() do con::Context
            group!(con, "layer1") do g::Group
                Gattino.text!(g, 5, 5, "tests", "fill" => "white")
                Gattino.line!(g, 5 => 5, 5 => 10)
            end
            group!(con, "scaledl") do g::Group
                Gattino.line!(g, [5, 10, 15], [5, 10, 15])
                Gattino.line!(g, ['c', 'd', 'a'], [5, 10, 15])
            end
            group!(con, "grid") do g::Group
                Gattino.grid!(g, 4)
                Gattino.gridlabels!(g, [5, 10, 15], [5, 10, 15], 4)
            end
            Gattino.labeled_grid!(con, [5, 10, 15], [5, 10, 15], [10], [10])
            group!(con, "points2") do g::Group
                Gattino.points!(g, randn(100), randn(100))
            end
            group!(con, "back") do g::Group
                axislabels!(g, "hello", "world")
                axes!(g)
            end
            group!(con, "bars") do g::Group
                Gattino.hist_plot!(g, [5, 10, 15], [32, 26, 23])
            end
            group!(con, "moreplots") do g::Group
                Gattino.scatter_plot!(g, [5, 10, 15], [5, 10, 11])
                Gattino.line_plot!(g, ["h", "o", "a", "a"], [5, 20, 11, 8])
            end
        end
        @testset "line and text annotations" begin
            @test length(con.window[:children]["layer1"][:children]) == 2
            @test con.window[:children]["layer1"][:children][1]["text"] == "tests"
        end
        @testset "grid" begin
            @test length(con.window[:children]["grid"]) == 16
        end
        @testset "feature plotting (points, bars, line!)" begin

        end
    end
end