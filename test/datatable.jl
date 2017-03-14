module TestDataTable
    using Base.Test
    using DataTables, Compat
    import Compat.String

    #
    # Equality
    #

    @test isequal(DataTable(a=[1, 2, 3], b=[4, 5, 6]), DataTable(a=[1, 2, 3], b=[4, 5, 6]))
    @test !isequal(DataTable(a=[1, 2], b=[4, 5]), DataTable(a=[1, 2, 3], b=[4, 5, 6]))
    @test !isequal(DataTable(a=[1, 2, 3], b=[4, 5, 6]), DataTable(a=[1, 2, 3]))
    @test !isequal(DataTable(a=[1, 2, 3], b=[4, 5, 6]), DataTable(a=[1, 2, 3], c=[4, 5, 6]))
    @test !isequal(DataTable(a=[1, 2, 3], b=[4, 5, 6]), DataTable(b=[4, 5, 6], a=[1, 2, 3]))
    @test !isequal(DataTable(a=[1, 2, 2], b=[4, 5, 6]), DataTable(a=[1, 2, 3], b=[4, 5, 6]))
    @test isequal(DataTable(a=Nullable{Int}[1, 2, Nullable()], b=[4, 5, 6]),
                  DataTable(a=Nullable{Int}[1, 2, Nullable()], b=[4, 5, 6]))

    # FIXME: equality operators won't work until JuliaStats/NullableArrays#84 is merged
    #@test get(DataTable(a=[1, 2, 3], b=[4, 5, 6]) == DataTable(a=[1, 2, 3], b=[4, 5, 6]))
    #@test get(DataTable(a=[1, 2], b=[4, 5]) != DataTable(a=[1, 2, 3], b=[4, 5, 6]))
    #@test get(DataTable(a=[1, 2, 3], b=[4, 5, 6]) != DataTable(a=[1, 2, 3]))
    #@test get(DataTable(a=[1, 2, 3], b=[4, 5, 6]) != DataTable(a=[1, 2, 3], c=[4, 5, 6]))
    #@test get(DataTable(a=[1, 2, 3], b=[4, 5, 6]) != DataTable(b=[4, 5, 6], a=[1, 2, 3]))
    #@test get(DataTable(a=[1, 2, 2], b=[4, 5, 6]) != DataTable(a=[1, 2, 3], b=[4, 5, 6]))
    #@test get(DataTable(a=Nullable{Int}[1, 3, Nullable()], b=[4, 5, 6]) !=
    #          DataTable(a=Nullable{Int}[1, 2, Nullable()], b=[4, 5, 6]))
    #@test isnull(DataTable(a=Nullable{Int}[1, 2, Nullable()], b=[4, 5, 6]) ==
    #             DataTable(a=Nullable{Int}[1, 2, Nullable()], b=[4, 5, 6]))
    #@test isnull(DataTable(a=Nullable{Int}[1, 2, Nullable()], b=[4, 5, 6]) ==
    #             DataTable(a=Nullable{Int}[1, 2, 3], b=[4, 5, 6]))

    #
    # Copying
    #

    dt = DataTable(a = [2, 3], b = Any[DataTable(c = 1), DataTable(d = 2)])
    dtc = copy(dt)
    dtdc = deepcopy(dt)

    dt[1, :a] = 4
    dt[1, :b][:e] = 5
    names!(dt, [:f, :g])

    @test names(dtc) == [:a, :b]
    @test names(dtdc) == [:a, :b]

    @test dtc[1, :a] === 4
    @test dtdc[1, :a] === 2

    @test names(dtc[1, :b]) == [:c, :e]
    @test names(dtdc[1, :b]) == [:c]

    #

    x = DataTable(a = [1, 2, 3], b = [4, 5, 6])
    v = DataTable(a = [5, 6, 7], b = [8, 9, 10])

    z = vcat(v, x)

    z2 = z[:, [1, 1, 2]]
    @test names(z2) == [:a, :a_1, :b]

    #test_group("DataTable assignment")
    # Insert single column
    x0 = x[Int[], :]
    @test_throws ErrorException x0[:d] = [1]
    @test_throws ErrorException x0[:d] = 1:3

    # Insert single value
    x[:d] = 3
    @test x[:d] == [3, 3, 3]

    x0[:d] = 3
    @test x0[:d] == Int[]

    # Associative methods

    dt = DataTable(a=[1, 2], b=[3., 4.])
    @test haskey(dt, :a)
    @test !haskey(dt, :c)
    @test get(dt, :a, -1) === dt.columns[1]
    @test get(dt, :c, -1) == -1
    @test !isempty(dt)

    @test empty!(dt) === dt
    @test isempty(dt.columns)
    @test isempty(dt)

    dt = DataTable(a=[1, 2], b=[3., 4.])
    @test_throws BoundsError insert!(dt, 5, ["a", "b"], :newcol)
    @test_throws ErrorException insert!(dt, 1, ["a"], :newcol)
    @test isequal(insert!(dt, 1, ["a", "b"], :newcol), dt)
    @test names(dt) == [:newcol, :a, :b]
    @test dt[:a] == [1, 2]
    @test dt[:b] == [3., 4.]
    @test dt[:newcol] == ["a", "b"]

    dt = DataTable(a=[1, 2], b=[3., 4.])
    dt2 = DataTable(b=["a", "b"], c=[:c, :d])
    @test isequal(merge!(dt, dt2), dt)
    @test isequal(dt, DataTable(a=[1, 2], b=["a", "b"], c=[:c, :d]))

    #test_group("Empty DataTable constructors")
    dt = DataTable(Int, 10, 3)
    @test size(dt, 1) == 10
    @test size(dt, 2) == 3
    @test typeof(dt[:, 1]) == Vector{Int}
    @test typeof(dt[:, 2]) == Vector{Int}
    @test typeof(dt[:, 3]) == Vector{Int}
    @test !anynull(dt[:, 1])
    @test !anynull(dt[:, 2])
    @test !anynull(dt[:, 3])

    dt = DataTable([Int, Float64, String], 100)
    @test size(dt, 1) == 100
    @test size(dt, 2) == 3
    @test typeof(dt[:, 1]) == Vector{Int}
    @test typeof(dt[:, 2]) == Vector{Float64}
    @test typeof(dt[:, 3]) == Vector{String}
    @test !anynull(dt[:, 1])
    @test !anynull(dt[:, 2])
    # array of #undef
    # @test !anynull(dt[:, 3])

    dt = DataTable([Int, Float64, String], [:A, :B, :C], 100)
    @test size(dt, 1) == 100
    @test size(dt, 2) == 3
    @test typeof(dt[:, 1]) == Vector{Int}
    @test typeof(dt[:, 2]) == Vector{Float64}
    @test typeof(dt[:, 3]) == Vector{String}
    @test !anynull(dt[:, 1])
    @test !anynull(dt[:, 2])
    # array of #undef
    # @test !anynull(dt[:, 3])


    dt = DataTable(DataType[Int, Float64, Compat.UTF8String],[:A, :B, :C], [false,false,true],100)
    @test size(dt, 1) == 100
    @test size(dt, 2) == 3
    @test typeof(dt[:, 1]) == Vector{Int}
    @test typeof(dt[:, 2]) == Vector{Float64}
    @test typeof(dt[:, 3]) == CategoricalVector{Compat.UTF8String,UInt32}
    @test !anynull(dt[:, 1])
    @test !anynull(dt[:, 2])
    # @test !anynull(dt[:, 3])


    dt = convert(DataTable, zeros(10, 5))
    @test size(dt, 1) == 10
    @test size(dt, 2) == 5
    @test typeof(dt[:, 1]) == Vector{Float64}

    dt = convert(DataTable, ones(10, 5))
    @test size(dt, 1) == 10
    @test size(dt, 2) == 5
    @test typeof(dt[:, 1]) == Vector{Float64}

    dt = convert(DataTable, eye(10, 5))
    @test size(dt, 1) == 10
    @test size(dt, 2) == 5
    @test typeof(dt[:, 1]) == Vector{Float64}

    # test_group("Other DataTable constructors")

    @test DataTable([[1,2,3],[2.5,4.5,6.5]], [:A, :B]) == DataTable(A = [1,2,3], B = [2.5,4.5,6.5])

    # This assignment was missing before
    dt = DataTable(Column = [:A])
    dt[1, :Column] = "Testing"

    # zero-row datatable and subdatatable test
    dt = DataTable(x=[], y=[])
    @test nrow(dt) == 0
    dt = DataTable(x=[1:3;], y=[3:5;])
    sdt = view(dt, dt[:x] .== 4)
    @test size(sdt, 1) == 0

    @test hash(convert(DataTable, [1 2; 3 4])) == hash(convert(DataTable, [1 2; 3 4]))
    @test hash(convert(DataTable, [1 2; 3 4])) != hash(convert(DataTable, [1 3; 2 4]))


    # push!(dt, row)
    dt=DataTable( first=[1,2,3], second=["apple","orange","pear"] )

    dtb= DataTable( first=[1,2], second=["apple","orange"] )
    push!(dtb, Any[3,"pear"])
    @test isequal(dt, dtb)

    dtb= DataTable( first=[1,2], second=["apple","orange"] )
    push!(dtb, (3,"pear"))
    @test isequal(dt, dtb)

    dtb= DataTable( first=[1,2], second=["apple","orange"] )
    @test_throws ArgumentError push!(dtb, (33.33,"pear"))

    dtb= DataTable( first=[1,2], second=["apple","orange"] )
    @test_throws ArgumentError push!(dtb, ("coconut",22))

    dtb= DataTable( first=[1,2], second=["apple","orange"] )
    push!(dtb, @compat(Dict(:first=>3, :second=>"pear")))
    @test isequal(dt, dtb)

    dt=DataTable( first=[1,2,3], second=["apple","orange","banana"] )
    dtb= DataTable( first=[1,2], second=["apple","orange"] )
    push!(dtb, @compat(Dict("first"=>3, "second"=>"banana")))
    @test isequal(dt, dtb)

    dt0= DataTable( first=[1,2], second=["apple","orange"] )
    dtb= DataTable( first=[1,2], second=["apple","orange"] )
    @test_throws ArgumentError push!(dtb, @compat(Dict(:first=>true, :second=>false)))
    @test isequal(dt0, dtb)

    dt0= DataTable( first=[1,2], second=["apple","orange"] )
    dtb= DataTable( first=[1,2], second=["apple","orange"] )
    @test_throws ArgumentError push!(dtb, @compat(Dict("first"=>"chicken", "second"=>"stuff")))
    @test isequal(dt0, dtb)

    # delete!
    dt = DataTable(a=1, b=2, c=3, d=4, e=5)
    @test_throws ArgumentError delete!(dt, 0)
    @test_throws ArgumentError delete!(dt, 6)
    @test_throws KeyError delete!(dt, :f)

    d = copy(dt)
    delete!(d, [:a, :e, :c])
    @test names(d) == [:b, :d]
    delete!(d, :b)
    @test isequal(d, dt[[:d]])

    d = copy(dt)
    delete!(d, [2, 5, 3])
    @test names(d) == [:a, :d]
    delete!(d, 2)
    @test isequal(d, dt[[:a]])

    # deleterows!
    dt = DataTable(a=[1, 2], b=[3., 4.])
    @test deleterows!(dt, 1) === dt
    @test isequal(dt, DataTable(a=[2], b=[4.]))

    dt = DataTable(a=[1, 2], b=[3., 4.])
    @test deleterows!(dt, 2) === dt
    @test isequal(dt, DataTable(a=[1], b=[3.]))

    dt = DataTable(a=[1, 2, 3], b=[3., 4., 5.])
    @test deleterows!(dt, 2:3) === dt
    @test isequal(dt, DataTable(a=[1], b=[3.]))

    dt = DataTable(a=[1, 2, 3], b=[3., 4., 5.])
    @test deleterows!(dt, [2, 3]) === dt
    @test isequal(dt, DataTable(a=[1], b=[3.]))

    dt = DataTable(a=NullableArray([1, 2]), b=NullableArray([3., 4.]))
    @test deleterows!(dt, 1) === dt
    @test isequal(dt, DataTable(a=NullableArray([2]), b=NullableArray([4.])))

    dt = DataTable(a=NullableArray([1, 2]), b=NullableArray([3., 4.]))
    @test deleterows!(dt, 2) === dt
    @test isequal(dt, DataTable(a=NullableArray([1]), b=NullableArray([3.])))

    dt = DataTable(a=NullableArray([1, 2, 3]), b=NullableArray([3., 4., 5.]))
    @test deleterows!(dt, 2:3) === dt
    @test isequal(dt, DataTable(a=NullableArray([1]), b=NullableArray([3.])))

    dt = DataTable(a=NullableArray([1, 2, 3]), b=NullableArray([3., 4., 5.]))
    @test deleterows!(dt, [2, 3]) === dt
    @test isequal(dt, DataTable(a=NullableArray([1]), b=NullableArray([3.])))

    # describe
    #suppress output and test that describe() does not throw
    devnull = is_unix() ? "/dev/null" : "nul"
    open(devnull, "w") do f
        @test nothing == describe(f, DataTable(a=[1, 2], b=Any["3", Nullable()]))
        @test nothing ==
              describe(f, DataTable(a=NullableArray([1, 2]),
                                    b=NullableArray(Nullable{String}["3", Nullable()])))
        @test nothing ==
              describe(f, DataTable(a=CategoricalArray([1, 2]),
                                    b=NullableCategoricalArray(Nullable{String}["3", Nullable()])))
        @test nothing == describe(f, [1, 2, 3])
        @test nothing == describe(f, NullableArray([1, 2, 3]))
        @test nothing == describe(f, CategoricalArray([1, 2, 3]))
        @test nothing == describe(f, Any["1", "2", Nullable()])
        @test nothing == describe(f, NullableArray(Nullable{String}["1", "2", Nullable()]))
        @test nothing == describe(f, NullableCategoricalArray(Nullable{String}["1", "2", Nullable()]))
    end

    dt = DataTable(Fish = CategoricalArray(["Bob", "Bob", "Batman", "Batman"]),
                   Key = ["Mass", "Color", "Mass", "Color"],
                   Value = ["12 g", "Red", "18 g", "Grey"])
    # Check that reordering levels does not confuse unstack
    levels!(dt[1], ["XXX", "Bob", "Batman"])
    #Unstack specifying a row column
    dt2 = unstack(dt, :Fish, :Key, :Value)
    #Unstack without specifying a row column
    dt3 = unstack(dt, :Key, :Value)
    #The expected output
    dt4 = DataTable(Fish = ["Bob", "Batman"],
                    Mass = ["12 g", "18 g"],
                    Color = ["Red", "Grey"] )
    @test isequal(dt2, dt4)
    @test isequal(dt3, dt4)
    # can't assign Nullable() to a typed column
    #Make sure unstack works with NULLs at the start of the value column
    # dt[1,:Value] = Nullable()
    dt2 = unstack(dt,:Fish, :Key, :Value)

    dt = DataTable(A = 1:10, B = 'A':'J')
    @test !(dt[:,:] === dt)

    @test append!(DataTable(A = 1:2, B = 1:2), DataTable(A = 3:4, B = 3:4)) == DataTable(A=1:4, B = 1:4)
    @test !any(c -> isa(c, CategoricalArray), categorical!(DataTable(A=1:3, B=4:6)).columns)
    @test all(c -> isa(c, CategoricalArray), categorical!(DataTable(A=1:3, B=4:6), [1,2]).columns)
    @test all(c -> isa(c, CategoricalArray), categorical!(DataTable(A=1:3, B=4:6), [:A,:B]).columns)
    @test find(c -> isa(c, CategoricalArray), categorical!(DataTable(A=1:3, B=4:6), [:A]).columns) == [1]
    @test find(c -> isa(c, CategoricalArray), categorical!(DataTable(A=1:3, B=4:6), :A).columns) == [1]
    @test find(c -> isa(c, CategoricalArray), categorical!(DataTable(A=1:3, B=4:6), [1]).columns) == [1]
    @test find(c -> isa(c, CategoricalArray), categorical!(DataTable(A=1:3, B=4:6), 1).columns) == [1]
end
