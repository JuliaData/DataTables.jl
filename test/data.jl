module TestData
    using Base.Test, DataTables, Nulls
    importall Base # so that we get warnings for conflicts

    #test_group("Vector creation")
    nvint = [1, 2, null, 4]
    nvint2 = 5:8
    nvint3 = 5:8
    nvflt = [1.0, 2.0, null, 4.0]
    nvstr = ["one", "two", null, "four"]
    dvdict = Vector{Dict}(4)    # for issue #199

    #test_group("constructors")
    dt1 = DataTable(Any[nvint, nvstr], [:Ints, :Strs])
    dt2 = DataTable(Any[nvint, nvstr])
    dt3 = DataTable(Any[nvint])
    dt4 = DataTable(Any[1:4, 1:4])
    dt5 = DataTable(Any[[1,2,3,4], nvstr])
    dt6 = DataTable(Any[nvint, nvint, nvstr], [:A, :B, :C])
    dt7 = DataTable(x = nvint, y = nvstr)
    @test size(dt7) == (4, 2)
    @test dt7[:x] == nvint

    #test_group("description functions")
    @test size(dt6, 1) == 4
    @test size(dt6, 2) == 3
    @test names(dt6) == [:A, :B, :C]
    @test names(dt2) == [:x1, :x2]
    @test names(dt7) == [:x, :y]

    #test_group("ref")
    @test dt6[2, 3] == "two"
    @test isnull(dt6[3, 3])
    @test dt6[2, :C] == "two"
    @test dt6[:B] == nvint
    @test size(dt6[[2,3]], 2) == 2
    @test size(dt6[2,:], 1) == 1
    @test size(dt6[[1, 3], [1, 3]]) == (2, 2)
    @test size(dt6[1:2, 1:2]) == (2, 2)
    @test size(head(dt6,2)) == (2, 3)
    # lots more to do

    #test_group("assign")
    dt6[3] = ["un", "deux", "trois", "quatre"]
    @test dt6[1, 3] == "un"
    dt6[:B] = [4, 3, 2, 1]
    @test dt6[1,2] == 4
    dt6[:D] = [true, false, true, false]
    @test dt6[1,4]
    delete!(dt6, :D)
    @test names(dt6) == [:A, :B, :C]
    @test size(dt6, 2) == 3

    #test_group("null handling")
    @test nrow(dt5[completecases(dt5), :]) == 3
    @test nrow(dropnull(dt5)) == 3
    returned = dropnull(dt4)
    @test dt4 == returned && dt4 !== returned
    @test nrow(dropnull!(dt5)) == 3
    returned = dropnull!(dt4)
    @test dt4 == returned && dt4 === returned

    #test_context("SubDataTables")

    #test_group("constructors")
    # single index is rows
    sdt6a = view(dt6, 1)
    sdt6b = view(dt6, 2:3)
    sdt6c = view(dt6, [true, false, true, false])
    @test size(sdt6a) == (1,3)
    sdt6d = view(dt6, [1,3], :B)
    @test size(sdt6d) == (2,1)

    #test_group("ref")
    @test sdt6a[1,2] == 4

    #test_context("Within")
    #test_group("Associative")

    #test_group("DataTable")
    srand(1)
    N = 20
    #Cast to Int64 as rand() behavior differs between Int32/64
    d1 = rand(map(Int64, 1:2), N)
    d2 = NullableCategoricalArray(["A", "B", null])[rand(map(Int64, 1:3), N)]
    d3 = randn(N)
    d4 = randn(N)
    dt7 = DataTable(Any[d1, d2, d3], [:d1, :d2, :d3])

    #test_group("groupby")
    gd = groupby(dt7, :d1)
    @test length(gd) == 2
    # @test gd[2]["d2"] == CategoricalVector["A", "B", null, "A", null, null, null, null]
    @test sum(gd[2][:d3]) == sum(dt7[:d3][dt7[:d1] .== 2])

    g1 = groupby(dt7, [:d1, :d2])
    g2 = groupby(dt7, [:d2, :d1])
    @test sum(g1[1][:d3]) == sum(g2[1][:d3])

    res = 0.0
    for x in g1
        res += sum(x[:d1])
    end
    @test res == sum(dt7[:d1])

    @test aggregate(DataTable(a=1), identity) == DataTable(a_identity=1)

    dt8 = aggregate(dt7[[1, 3]], sum)
    @test dt8[1, :d1_sum] == sum(dt7[:d1])

    dt8 = aggregate(dt7, :d2, [sum, length], sort=true)
    @test dt8[1:2, :d2] == NullableCategoricalArray(["A", "B"])
    @test size(dt8, 1) == 3
    @test size(dt8, 2) == 5
    @test sum(dt8[:d1_length]) == N
    @test all(dt8[:d1_length] .> 0)
    @test dt8[:d1_length] == [4, 5, 11]
    @test dt8 == aggregate(groupby(dt7, :d2, sort=true), [sum, length])
    @test dt8[1, :d1_length] == 4
    @test dt8[2, :d1_length] == 5
    @test dt8[3, :d1_length] == 11
    @test dt8 == aggregate(groupby(dt7, :d2), [sum, length], sort=true)

    dt9 = dt7 |> groupby([:d2], sort=true) |> [sum, length]
    @test dt9 == dt8
    dt9 = aggregate(dt7, :d2, [sum, length], sort=true)
    @test dt9 == dt8

    dt10 = DataTable(
        Any[[1:4;], [2:5;], ["a", "a", "a", "b" ], ["c", "d", "c", "d"]],
        [:d1, :d2, :d3, :d4]
    )

    gd = groupby(dt10, [:d3], sort=true)
    ggd = groupby(gd[1], [:d3, :d4], sort=true) # make sure we can groupby subdatatables
    @test ggd[1][1, :d3] == "a"
    @test ggd[1][1, :d4] == "c"
    @test ggd[1][2, :d3] == "a"
    @test ggd[1][2, :d4] == "c"
    @test ggd[2][1, :d3] == "a"
    @test ggd[2][1, :d4] == "d"

    #test_group("reshape")
    d1 = DataTable(a = repeat([1:3;], inner = [4]),
                   b = repeat([1:4;], inner = [3]),
                   c = randn(12),
                   d = randn(12),
                   e = map(string, 'a':'l'))

    stack(d1, :a)
    d1s = stack(d1, [:a, :b])
    d1s2 = stack(d1, [:c, :d])
    d1s3 = stack(d1)
    d1m = melt(d1, [:c, :d, :e])
    @test d1s[1:12, :c] == d1[:c]
    @test d1s[13:24, :c] == d1[:c]
    @test d1s2 == d1s3
    @test names(d1s) == [:variable, :value, :c, :d, :e]
    @test d1s == d1m
    d1m = melt(d1[[1,3,4]], :a)
    @test names(d1m) == [:variable, :value, :a]

    # Test naming of measure/value columns
    d1s_named = stack(d1, [:a, :b], variable_name=:letter, value_name=:someval)
    @test names(d1s_named) == [:letter, :someval, :c, :d, :e]
    d1m_named = melt(d1[[1,3,4]], :a, variable_name=:letter, value_name=:someval)
    @test names(d1m_named) == [:letter, :someval, :a]

    stackdt(d1, :a)
    d1s = stackdt(d1, [:a, :b])
    d1s2 = stackdt(d1, [:c, :d])
    d1s3 = stackdt(d1)
    d1m = meltdt(d1, [:c, :d, :e])
    @test d1s[1:12, :c] == d1[:c]
    @test d1s[13:24, :c] == d1[:c]
    @test d1s2 == d1s3
    @test names(d1s) == [:variable, :value, :c, :d, :e]
    @test d1s == d1m
    d1m = meltdt(d1[[1,3,4]], :a)
    @test names(d1m) == [:variable, :value, :a]

    d1s_named = stackdt(d1, [:a, :b], variable_name=:letter, value_name=:someval)
    @test names(d1s_named) == [:letter, :someval, :c, :d, :e]
    d1m_named = meltdt(d1, [:c, :d, :e], variable_name=:letter, value_name=:someval)
    @test names(d1m_named) == [:letter, :someval, :c, :d, :e]

    d1s[:id] = [1:12; 1:12]
    d1s2[:id] =  [1:12; 1:12]
    d1us = unstack(d1s, :id, :variable, :value)
    d1us2 = unstack(d1s2)
    d1us3 = unstack(d1s2, :variable, :value)
    @test d1us[:a] == d1[:a]
    @test d1us2[:d] == d1[:d]
    @test d1us2[:3] == d1[:d]

    #test_group("merge")

    srand(1)
    dt1 = DataTable(a = shuffle!(collect(1:10)),
                    b = rand([:A,:B], 10),
                    v1 = randn(10))

    dt2 = DataTable(a = shuffle!(collect(1:5)),
                    b2 = rand([:A,:B,:C], 5),
                    v2 = randn(5))

    m1 = join(dt1, dt2, on = :a, kind=:inner)
    @test m1[:a] == dt1[:a][dt1[:a] .<= 5] # preserves dt1 order
    m2 = join(dt1, dt2, on = :a, kind = :outer)
    @test m2[:a] == dt1[:a] # preserves dt1 order
    @test m2[:b] == dt1[:b] # preserves dt1 order
    m2 = join(dt1, dt2, on = :a, kind = :outer)
    @test m2[:b2] == [null, :A, :A, null, :C, null, null, :B, null, :A]

    dt1 = DataTable(a = [1, 2, 3],
                    b = ["America", "Europe", "Africa"])
    dt2 = DataTable(a = [1, 2, 4],
                    c = ["New World", "Old World", "New World"])

    m1 = join(dt1, dt2, on = :a, kind = :inner)
    @test m1[:a] == [1, 2]

    m2 = join(dt1, dt2, on = :a, kind = :left)
    @test m2[:a] == [1, 2, 3]

    m3 = join(dt1, dt2, on = :a, kind = :right)
    @test m3[:a] == [1, 2, 4]

    m4 = join(dt1, dt2, on = :a, kind = :outer)
    @test m4[:a] == [1, 2, 3, 4]

    # test with nulls (issue #185)
    dt1 = DataTable()
    dt1[:A] = ["a", "b", "a", null]
    dt1[:B] = [1, 2, 1, 3]

    dt2 = DataTable()
    dt2[:A] = ["a", null, "c"]
    dt2[:C] = [1, 2, 4]

    m1 = join(dt1, dt2, on = :A)
    @test size(m1) == (3,3)
    @test m1[:A] == ["a","a", null]

    m2 = join(dt1, dt2, on = :A, kind = :outer)
    @test size(m2) == (5,3)
    @test m2[:A] == ["a", "b", "a", null, "c"]

    srand(1)
    dt1 = DataTable(
        a = rand([:x,:y], 10),
        b = rand([:A,:B], 10),
        v1 = randn(10)
    )

    dt2 = DataTable(
        a = Vector{?Symbol}([:x,:y][[1,2,1,1,2]]),
        b = [:A,:B,:C][[1,1,1,2,3]],
        v2 = randn(5)
    )
    dt2[1,:a] = null

    # # TODO: Restore this functionality
    # m1 = join(dt1, dt2, on = [:a,:b])
    # @test m1[:a] == Vector(["x", "x", "y", "y", fill("x", 5)]))
    # m2 = join(dt1, dt2, on = ["a","b"], kind = :outer)
    # @test m2[10,:v2] == null
    # @test m2[:a] ==
    #               (?String)["x", "x", "y", "y",
    #                         "x", "x", "x", "x", "x", "y",
    #                         null, "y"]

    srand(1)
    function spltdt(d)
        d[:x1] = map(x -> x[1], d[:a])
        d[:x2] = map(x -> x[2], d[:a])
        d[:x3] = map(x -> x[3], d[:a])
        d
    end
    dt1 = DataTable(
        a = ["abc", "abx", "axz", "def", "dfr"],
        v1 = randn(5)
    )
    dt1 = spltdt(dt1)
    dt2 = DataTable(
        a = ["def", "abc","abx", "axz", "xyz"],
        v2 = randn(5)
    )
    dt2 = spltdt(dt2)

    m1 = join(dt1, dt2, on = :a)
    m2 = join(dt1, dt2, on = [:x1, :x2, :x3])
    @test sort(m1[:a]) == sort(m2[:a])

    # test nonunique() with extra argument
    dt1 = DataTable(a = ["a", "b", "a", "b", "a", "b"],
                    b = 1:6,
                    c = [1:3;1:3])
    dt = vcat(dt1, dt1)
    @test find(nonunique(dt)) == collect(7:12)
    @test find(nonunique(dt, :)) == collect(7:12)
    @test find(nonunique(dt, Colon())) == collect(7:12)
    @test find(nonunique(dt, :a)) == collect(3:12)
    @test find(nonunique(dt, [:a, :c])) == collect(7:12)
    @test find(nonunique(dt, [1, 3])) == collect(7:12)
    @test find(nonunique(dt, 1)) == collect(3:12)

    # Test unique() with extra argument
    @test unique(dt) == dt1
    @test unique(dt, :) == dt1
    @test unique(dt, Colon()) == dt1
    @test unique(dt, 2:3) == dt1
    @test unique(dt, 3) == dt1[1:3,:]
    @test unique(dt, [1, 3]) == dt1
    @test unique(dt, [:a, :c]) == dt1
    @test unique(dt, :a) == dt1[1:2,:]

    #test unique!() with extra argument
    unique!(dt, [1, 3])
    @test dt == dt1
end
