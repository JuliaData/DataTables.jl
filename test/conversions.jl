module TestConversions
    using Base.Test
    using DataTables, Nulls
    using DataStructures: OrderedDict, SortedDict

    dt = DataTable()
    dt[:A] = 1:5
    dt[:B] = [:A, :B, :C, :D, :E]
    @test isa(convert(Array, dt), Matrix{Any})
    @test isa(convert(Array{Any}, dt), Matrix{Any})

    dt = DataTable()
    dt[:A] = 1:5
    dt[:B] = 1.0:5.0
    @test isa(convert(Array, dt), Matrix{Float64})
    @test isa(convert(Array{Any}, dt), Matrix{Any})
    @test isa(convert(Array{Float64}, dt), Matrix{Float64})

    dt = DataTable()
    dt[:A] = Vector(1.0:5.0)
    dt[:B] = Vector(1.0:5.0)
    a = convert(Array, dt)
    aa = convert(Array{Any}, dt)
    ai = convert(Array{Int}, dt)
    @test isa(a, Matrix{Float64})
    @test a == convert(Matrix, dt)
    @test isa(aa, Matrix{Any})
    @test aa == convert(Matrix{Any}, dt)
    @test isa(ai, Matrix{Int})
    @test ai == convert(Matrix{Int}, dt)

    @test_throws MethodError dt[1,1] = null
    dt[:A] = Vector{?Float64}(1.0:5.0)
    dt[1, 1] = null
    na = convert(Array{?Float64}, dt)
    naa = convert(Array{?Any}, dt)
    nai = convert(Array{?Int}, dt)
    @test isa(na, Matrix{?Float64})
    @test isequal(na, convert(Matrix, dt))
    @test isa(naa, Matrix{?Any})
    @test isequal(naa, convert(Matrix{?Any}, dt))
    @test isa(nai, Matrix{?Int})
    @test isequal(nai, convert(Matrix{?Int}, dt))

    a = Vector([1.0,2.0])
    b = Vector([-0.1,3])
    c = Vector([-3.1,7])
    di = Dict("a"=>a, "b"=>b, "c"=>c)

    dt = convert(DataTable, di)
    @test isa(dt, DataTable)
    @test names(dt) == Symbol[x for x in sort(collect(keys(di)))]
    @test isequal(dt[:a], Vector(a))
    @test isequal(dt[:b], Vector(b))
    @test isequal(dt[:c], Vector(c))

    od = OrderedDict("c"=>c, "a"=>a, "b"=>b)
    dt = convert(DataTable,od)
    @test isa(dt, DataTable)
    @test names(dt) == Symbol[x for x in keys(od)]
    @test isequal(dt[:a], Vector(a))
    @test isequal(dt[:b], Vector(b))
    @test isequal(dt[:c], Vector(c))

    sd = SortedDict("c"=>c, "a"=>a, "b"=>b)
    dt = convert(DataTable,sd)
    @test isa(dt, DataTable)
    @test names(dt) == Symbol[x for x in keys(sd)]
    @test isequal(dt[:a], Vector(a))
    @test isequal(dt[:b], Vector(b))
    @test isequal(dt[:c], Vector(c))

    a = [1.0]
    di = Dict("a"=>a, "b"=>b, "c"=>c)
    @test_throws DimensionMismatch convert(DataTable,di)

end
