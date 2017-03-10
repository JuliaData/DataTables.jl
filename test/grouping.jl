module TestGrouping
    using Base.Test
    using DataTables

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

    @test all(T -> T <: AbstractVector, map(typeof, colwise([sum], dt)))
    @test all(T -> T <: AbstractVector, map(typeof, colwise(sum, dt)))

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
    x = categorical(collect(1:20))
    dt = DataTable(v1=x, v2=x)
    groupby(dt, [:v1, :v2])

    # what is this testting?
    # dt2 = by(e->1, DataTable(x=Int64[]), :x)
    # @test size(dt2) == (0,1)
    # @test sum(dt2[:x]) == 0

    # Check that reordering levels does not confuse groupby
    dt = DataTable(Key1 = categorical(["A", "A", "B", "B"]),
                   Key2 = categorical(["A", "B", "A", "B"]),
                   Value = 1:4)
    gd = groupby(dt, :Key1)
    @test gd[1].parent[gd[1].rows, :] == DataTable(Key1 = categorical(["A", "A"]),
                                                   Key2 = categorical(["A", "B"]),
                                                   Value = collect(1:2))
    @test gd[2].parent[gd[2].rows, :] == DataTable(Key1 = categorical(["B", "B"]),
                                                   Key2 = categorical(["A", "B"]),
                                                   Value = collect(3:4))
    gd = groupby(dt, [:Key1, :Key2])
    @test gd[1].parent[gd[1].rows, :] == DataTable(Key1 = categorical(["A"]),
                                                   Key2 = categorical(["A"]),
                                                   Value = [1])
    @test gd[2].parent[gd[2].rows, :] == DataTable(Key1 = categorical(["A"]),
                                                   Key2 = categorical(["B"]),
                                                   Value = [2])
    @test gd[3].parent[gd[3].rows, :] == DataTable(Key1 = categorical(["B"]),
                                                   Key2 = categorical(["A"]),
                                                   Value = [3])
    @test gd[4].parent[gd[4].rows, :] == DataTable(Key1 = categorical(["B"]),
                                                   Key2 = categorical(["B"]),
                                                   Value = [4])
    # Reorder levels, add unused level
    levels!(dt[:Key1], ["Z", "B", "A"])
    levels!(dt[:Key2], ["Z", "B", "A"])
    gd = groupby(dt, :Key1)
    @test gd[1].parent[gd[1].rows, :] == DataTable(Key1 = categorical(["A", "A"]),
                                                   Key2 = categorical(["A", "B"]),
                                                   Value = collect(1:2))
    @test gd[2].parent[gd[2].rows, :] == DataTable(Key1 = categorical(["B", "B"]),
                                                   Key2 = categorical(["A", "B"]),
                                                   Value = collect(3:4))
    gd = groupby(dt, [:Key1, :Key2])
    @test gd[1].parent[gd[1].rows, :] == DataTable(Key1 = categorical(["A"]),
                                                   Key2 = categorical(["A"]),
                                                   Value = [1])
    @test gd[2].parent[gd[2].rows, :] == DataTable(Key1 = categorical(["A"]),
                                                   Key2 = categorical(["B"]),
                                                   Value = [2])
    @test gd[3].parent[gd[3].rows, :] == DataTable(Key1 = categorical(["B"]),
                                                   Key2 = categorical(["A"]),
                                                   Value = [3])
    @test gd[4].parent[gd[4].rows, :] == DataTable(Key1 = categorical(["B"]),
                                                   Key2 = categorical(["B"]),
                                                   Value = [4])

    @test names(gd) == names(dt)
end
