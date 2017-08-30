module TestSubDataTable
    using Base.Test, DataTables

    @testset "view -- DataTable" begin
        dt = DataTable(x = 1:10, y = 1.0:10.0)
        @test view(dt, 1) == head(dt, 1)
        @test view(dt, UInt(1)) == head(dt, 1)
        @test view(dt, BigInt(1)) == head(dt, 1)
        @test view(dt, 1:2) == head(dt, 2)
        @test view(dt, vcat(trues(2), falses(8))) == head(dt, 2)
        @test view(dt, [1, 2]) == head(dt, 2)
        @test view(dt, 1, :x) == head(dt[[:x]], 1)
        @test view(dt, 1:2, :x) == head(dt[[:x]], 2)
        @test view(dt, vcat(trues(2), falses(8)), :x) == head(dt[[:x]], 2)
        @test view(dt, [1, 2], :x) == head(dt[[:x]], 2)
        @test view(dt, 1, 1) == head(dt[[:x]], 1)
        @test view(dt, 1:2, 1) == head(dt[[:x]], 2)
        @test view(dt, vcat(trues(2), falses(8)), 1) == head(dt[[:x]], 2)
        @test view(dt, [1, 2], 1) == head(dt[[:x]], 2)
        @test view(dt, 1, [:x, :y]) == head(dt, 1)
        @test view(dt, 1:2, [:x, :y]) == head(dt, 2)
        @test view(dt, vcat(trues(2), falses(8)), [:x, :y]) == head(dt, 2)
        @test view(dt, [1, 2], [:x, :y]) == head(dt, 2)
        @test view(dt, 1, [1, 2]) == head(dt, 1)
        @test view(dt, 1:2, [1, 2]) == head(dt, 2)
        @test view(dt, vcat(trues(2), falses(8)), [1, 2]) == head(dt, 2)
        @test view(dt, [1, 2], [1, 2]) == head(dt, 2)
        @test view(dt, 1, trues(2)) == head(dt, 1)
        @test view(dt, 1:2, trues(2)) == head(dt, 2)
        @test view(dt, vcat(trues(2), falses(8)), trues(2)) == head(dt, 2)
        @test view(dt, [1, 2], trues(2)) == head(dt, 2)
        @test view(dt, Integer[1, 2]) == head(dt, 2)
        @test view(dt, UInt[1, 2]) == head(dt, 2)
        @test view(dt, BigInt[1, 2]) == head(dt, 2)
        @test view(dt, Union{Int, Null}[1, 2]) == head(dt, 2)
        @test view(dt, Union{Integer, Null}[1, 2]) == head(dt, 2)
        @test view(dt, Union{UInt, Null}[1, 2]) == head(dt, 2)
        @test view(dt, Union{BigInt, Null}[1, 2]) == head(dt, 2)
        @test_throws NullException view(dt, [null, 1])
    end

    @testset "view -- SubDataTable" begin
        dt = view(DataTable(x = 1:10, y = 1.0:10.0), 1:10)
        @test view(dt, 1) == head(dt, 1)
        @test view(dt, UInt(1)) == head(dt, 1)
        @test view(dt, BigInt(1)) == head(dt, 1)
        @test view(dt, 1:2) == head(dt, 2)
        @test view(dt, vcat(trues(2), falses(8))) == head(dt, 2)
        @test view(dt, [1, 2]) == head(dt, 2)
        @test view(dt, 1, :x) == head(dt[[:x]], 1)
        @test view(dt, 1:2, :x) == head(dt[[:x]], 2)
        @test view(dt, vcat(trues(2), falses(8)), :x) == head(dt[[:x]], 2)
        @test view(dt, [1, 2], :x) == head(dt[[:x]], 2)
        @test view(dt, 1, 1) == head(dt[[:x]], 1)
        @test view(dt, 1:2, 1) == head(dt[[:x]], 2)
        @test view(dt, vcat(trues(2), falses(8)), 1) == head(dt[[:x]], 2)
        @test view(dt, [1, 2], 1) == head(dt[[:x]], 2)
        @test view(dt, 1, [:x, :y]) == head(dt, 1)
        @test view(dt, 1:2, [:x, :y]) == head(dt, 2)
        @test view(dt, vcat(trues(2), falses(8)), [:x, :y]) == head(dt, 2)
        @test view(dt, [1, 2], [:x, :y]) == head(dt, 2)
        @test view(dt, 1, [1, 2]) == head(dt, 1)
        @test view(dt, 1:2, [1, 2]) == head(dt, 2)
        @test view(dt, vcat(trues(2), falses(8)), [1, 2]) == head(dt, 2)
        @test view(dt, [1, 2], [1, 2]) == head(dt, 2)
        @test view(dt, 1, trues(2)) == head(dt, 1)
        @test view(dt, 1:2, trues(2)) == head(dt, 2)
        @test view(dt, vcat(trues(2), falses(8)), trues(2)) == head(dt, 2)
        @test view(dt, [1, 2], trues(2)) == head(dt, 2)
        @test view(dt, Integer[1, 2]) == head(dt, 2)
        @test view(dt, UInt[1, 2]) == head(dt, 2)
        @test view(dt, BigInt[1, 2]) == head(dt, 2)
        @test view(dt, Union{Int, Null}[1, 2]) == head(dt, 2)
        @test view(dt, Union{Integer, Null}[1, 2]) == head(dt, 2)
        @test view(dt, Union{UInt, Null}[1, 2]) == head(dt, 2)
        @test view(dt, Union{BigInt, Null}[1, 2]) == head(dt, 2)
        @test_throws NullException view(dt, [null, 1])
    end
end
