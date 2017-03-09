module TestGrouping
    using Base.Test
    using DataTables

    srand(1)
    dt = DataTable(a = repeat([1, 2, 3, 4], outer=[2]),
                   b = repeat([2, 1], outer=[4]),
                   c = randn(8))
    #dt[6, :a] = Nullable()
    #dt[7, :b] = Nullable()

    cols = [:a, :b]

    f(dt) = DataTable(cmax = maximum(dt[:c]))

    sdt = unique(dt[cols])

    # by() without groups sorting
    bdt = by(dt, cols, f)
    @test bdt[cols] == sdt

    # by() with groups sorting
    sbdt = by(dt, cols, f, sort=true)
    @test sbdt[cols] == sort(sdt)

    byf = by(dt, :a, dt -> DataTable(bsum = sum(dt[:b])))

    # colwise(::Vector{<:Function}, ::AbstractDataTable)
    cw = colwise([sum], dt)
    @test isa(cw, NullableArray{Any, 2})
    @test size(cw) == (1,ncol(dt))
    answer = NullableArray([20 12 -0.4283098098931877])
    @test isequal(cw, answer)
    nullfree = DataTable(Any[collect(1:10)], [:x1])
    @test colwise([sum, minimum], nullfree) == reshape([55, 1], (2,1))
    # colwise(::Tuple{<:Function}, ::AbstractDataTable)
    cw = colwise((sum, length), dt)
    @test isa(cw, Array{Any, 2})
    @test size(cw) == (2,ncol(dt))
    answer = Any[Nullable(20) Nullable(12) Nullable(-0.4283098098931877);
                 8            8            8                            ]
    @test isequal(cw, answer)
    @test_throws MethodError colwise(("Bob", :Susie), DataTable(A = 1:10, B = 11:20))
    @test colwise((sum, minimum), nullfree) == reshape([55, 1], (2,1))
    # colwise(::Function, ::AbstractDataTable)
    cw = colwise(sum, dt)
    @test all(T -> isa(T, Nullable), cw)
    answer = NullableArray([20, 12, -0.4283098098931877])
    @test isequal(cw, answer)
    @test colwise(sum, nullfree) == [55]

    # colwise on GroupedDataTables
    gd = groupby(DataTable(A = [:A, :A, :B, :B], B = 1:4), :A)
    @test colwise(length, gd) == [[2,2], [2,2]]
    @test colwise([length], gd) == [[2 2], [2 2]]
    @test colwise((length), gd) == [[2,2],[2,2]]

    # map magic
    cw = map(colwise(sum), (nullfree, dt))
    answer = ([55], NullableArray([20, 12, -0.4283098098931877]))
    @test all(isequal(x,y) for (x,y) in zip(cw, answer))
    cw = map(colwise((sum, length)), (nullfree, dt))
    answer = (reshape([55, 10], (2,1)),
              Any[Nullable(20) Nullable(12) Nullable(-0.4283098098931877);
                  8            8            8                            ])
    @test all(isequal(x,y) for (x,y) in zip(cw, answer))
    cw = map(colwise([sum, length]), (nullfree, dt))
    @test all(isequal(x,y) for (x,y) in zip(cw, answer))

    # groupby() without groups sorting
    gd = groupby(dt, cols)
    ga = map(f, gd)

    @test isequal(bdt, combine(ga))

    # groupby() with groups sorting
    gd = groupby(dt, cols, sort=true)
    ga = map(f, gd)
    @test sbdt == combine(ga)

    g(dt) = DataTable(cmax1 = Vector(dt[:cmax]) + 1)
    h(dt) = g(f(dt))

    @test isequal(combine(map(h, gd)), combine(map(g, ga)))

    # testing pool overflow
    dt2 = DataTable(v1 = categorical(collect(1:1000)), v2 = categorical(fill(1, 1000)))
    @test groupby(dt2, [:v1, :v2]).starts == collect(1:1000)
    @test groupby(dt2, [:v2, :v1]).starts == collect(1:1000)

    # grouping empty table
    @test groupby(DataTable(A=Int[]), :A).starts == Int[]
    # grouping single row
    @test groupby(DataTable(A=Int[1]), :A).starts == Int[1]

    # issue #960
    x = CategoricalArray(collect(1:20))
    dt = DataTable(v1=x, v2=x)
    groupby(dt, [:v1, :v2])

    dt2 = by(e->1, DataTable(x=Int64[]), :x)
    @test size(dt2) == (0,1)
    @test isequal(sum(dt2[:x]), Nullable(0))

    # Check that reordering levels does not confuse groupby
    dt = DataTable(Key1 = CategoricalArray(["A", "A", "B", "B"]),
                   Key2 = CategoricalArray(["A", "B", "A", "B"]),
                   Value = 1:4)
    gd = groupby(dt, :Key1)
    @test isequal(gd[1], DataTable(Key1=["A", "A"], Key2=["A", "B"], Value=1:2))
    @test isequal(gd[2], DataTable(Key1=["B", "B"], Key2=["A", "B"], Value=3:4))
    gd = groupby(dt, [:Key1, :Key2])
    @test isequal(gd[1], DataTable(Key1="A", Key2="A", Value=1))
    @test isequal(gd[2], DataTable(Key1="A", Key2="B", Value=2))
    @test isequal(gd[3], DataTable(Key1="B", Key2="A", Value=3))
    @test isequal(gd[4], DataTable(Key1="B", Key2="B", Value=4))
    # Reorder levels, add unused level
    levels!(dt[:Key1], ["Z", "B", "A"])
    levels!(dt[:Key2], ["Z", "B", "A"])
    gd = groupby(dt, :Key1)
    @test isequal(gd[1], DataTable(Key1=["A", "A"], Key2=["A", "B"], Value=1:2))
    @test isequal(gd[2], DataTable(Key1=["B", "B"], Key2=["A", "B"], Value=3:4))
    gd = groupby(dt, [:Key1, :Key2])
    @test isequal(gd[1], DataTable(Key1="A", Key2="A", Value=1))
    @test isequal(gd[2], DataTable(Key1="A", Key2="B", Value=2))
    @test isequal(gd[3], DataTable(Key1="B", Key2="A", Value=3))
    @test isequal(gd[4], DataTable(Key1="B", Key2="B", Value=4))
end
