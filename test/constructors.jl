module TestConstructors
    using Base.Test
    using DataTables, DataTables.Index

    #
    # DataTable
    #

    dt = DataTable()
    @test isequal(dt.columns, Any[])
    @test isequal(dt.colindex, Index())

    dt = DataTable(Any[NullableCategoricalVector(zeros(3)),
                       NullableCategoricalVector(ones(3))],
                   Index([:x1, :x2]))
    @test size(dt, 1) == 3
    @test size(dt, 2) == 2

    @test isequal(dt, DataTable(Any[NullableCategoricalVector(zeros(3)),
                                    NullableCategoricalVector(ones(3))]))

    dt2 = convert(DataTable, [0.0 1.0;
                              0.0 1.0;
                              0.0 1.0])
    names!(dt2, [:x1, :x2])
    @test isequal(dt[:x1], NullableArray(dt2[:x1]))
    @test isequal(dt[:x2], NullableArray(dt2[:x2]))

    @test isequal(dt, DataTable(x1 = NullableArray([0.0, 0.0, 0.0]),
                                x2 = NullableArray([1.0, 1.0, 1.0])))
    @test isequal(dt, DataTable(x1 = NullableArray([0.0, 0.0, 0.0]),
                                x2 = NullableArray([1.0, 1.0, 1.0]),
                                x3 = [2.0, 2.0, 2.0])[[:x1, :x2]])

    dt = DataTable(Int, 2, 2)
    @test size(dt) == (2, 2)
    @test eltypes(dt) == [Int, Int]

    dt = DataTable([Nullable{Int}, Nullable{Float64}], [:x1, :x2], 2)
    @test size(dt) == (2, 2)
    @test eltypes(dt) == [Nullable{Int}, Nullable{Float64}]
    @test isequal(dt, DataTable([Nullable{Int}, Nullable{Float64}], 2))
    @test all(isnull, (dt[:x1], dt[:x2]))

    @test_throws BoundsError SubDataTable(DataTable(A=1), 0)
    @test_throws BoundsError SubDataTable(DataTable(A=1), 0)
    @test isequal(SubDataTable(DataTable(A=1), 1), DataTable(A=1))
    @test isequal(SubDataTable(DataTable(A=1:10), 1:4), DataTable(A=1:4))
    @test isequal(view(SubDataTable(DataTable(A=1:10), 1:4), 2), DataTable(A=2))
    @test isequal(view(SubDataTable(DataTable(A=1:10), 1:4), [true, true, false, false]), DataTable(A=1:2))

    @test DataTable(a=1, b=1:2) == DataTable(a=[1,1], b=[1,2])

    @testset "associative" begin
        dt = DataTable(Dict(:A => 1:3, :B => 4:6))
        @test dt == DataTable(A = 1:3, B = 4:6)
        @test all(e -> e <: Int, eltypes(dt))
    end

    @testset "recyclers" begin
        @test DataTable(a = 1:5, b = 1) == DataTable(a = collect(1:5), b = fill(1, 5))
        @test DataTable(a = 1, b = 1:5) == DataTable(a = fill(1, 5), b = collect(1:5))
    end

    @testset "constructor errors" begin
        @test_throws DimensionMismatch DataTable(a=1, b=[])
        @test_throws DimensionMismatch DataTable(Any[collect(1:10)], DataTables.Index([:A, :B]))
        @test_throws DimensionMismatch DataTable(A = rand(2,2))
        @test_throws DimensionMismatch DataTable(A = rand(2,1))
    end

    @testset "column types" begin
        dt = DataTable(A = 1:3, B = 2:4, C = 3:5)
        answer = Any[Array{Int,1}, Array{Int,1}, Array{Int,1}]
        @test map(typeof, dt.columns) == answer
        dt[:D] = NullableArray([4, 5, Nullable()])
        push!(answer, NullableArray{Int,1})
        @test map(typeof, dt.columns) == answer
        dt[:E] = 'c'
        push!(answer, Array{Char,1})
        @test map(typeof, dt.columns) == answer
    end

    @testset "null conversions" begin
        dt = DataTable(A = 1:3, B = 2:4, C = 3:5)
        nullfree = Any[Array{Int,1},Array{Int,1},Array{Int,1}]
        nullified = convert(Vector{Any}, fill(NullableArray{Int,1}, 3))
        @test map(typeof, nullify(dt).columns) == nullified
        @test sum(isa(dt[i,j], Nullable) for i=1:size(dt, 1) for j=1:size(dt, 2)) == 0
        nullify!(dt)
        @test map(typeof, dt.columns) == nullified
        @test sum(isa(dt[i,j], Nullable) for i=1:size(dt, 1) for j=1:size(dt, 2)) == reduce(*, size(dt))
        @test map(typeof, denullify(dt).columns) == nullfree
        @test sum(isa(dt[i,j], Nullable) for i=1:size(dt, 1) for j=1:size(dt, 2)) == reduce(*, size(dt))
        denullify!(dt)
        map(typeof, dt.columns) == nullfree
        @test sum(isa(dt[i,j], Nullable) for i=1:size(dt, 1) for j=1:size(dt, 2)) == 0

        dt = DataTable(A = [Nullable(i) for i=1:10])
        @test denullify!(dt).columns == Any[[i for i=1:10]]
    end
end
