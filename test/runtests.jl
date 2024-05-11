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
    @testset "contexts" verbose = true begin

    end
    @testset "context plotting" verbose = true begin

    end
end