using Test
using Gattino

df = Dict("A" => [5, 10, 15, 20], "B" => [1, 2, 3, 4])

@testset "gattino plots" verbose = true begin
    @testset "high-level plotting" verbose = true begin
        @testset "hist" begin
            ran = false
            h = nothing
            try
                h = hist(df)
                hist(df["A"], df["B"], ymin = 0, ymax = 50)
                hist(["1", "2", "3", "4", "5"], df["B"], ymin = 0, ymax = 50)
            catch

            end
            @test ran
            layers = [p[2] for p in layers(h)]
            @test "A" in layers
            @test "axes" in layers
        end
        @testset "scatter" begin
            ran = false
            h = nothing
            try
                scatter(df)
                h = scatter(df["A"], df["B"], ymin = 0, ymax = 50, title = "sample")
            catch

            end
            @test ran
            layers = [p[2] for p in layers(h)]
            @test "points" in layers
            @test length(h.window[:children]["points"][:children]) == length(df["A"])
            @test "axes" in layers
        end
        @testset "line" begin
            ran = false
            h = nothing
            try
                line(df)
                h = line(df["A"], df["B"], ymin = 0, ymax = 50, title = "sample")
                line(["hi", "hello"], df["A"][1:2])
            catch

            end
            @test ran
            layers = [p[2] for p in layers(h)]
            @test "points" in layers
            @test length(h.window[:children]["points"][:children]) == length(df["A"])
            @test "axes" in layers
        end
    end
end