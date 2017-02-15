module TestShow
    using DataTables
    using Compat
    using Base.Test
    import Compat.String
    df = DataTable(A = 1:3, B = ["x", "y", "z"])

    io = IOBuffer()
    show(io, df)
    show(io, df, true)
    showall(io, df)
    showall(io, df, true)

    subdf = view(df, [2, 3]) # df[df[:A] .> 1.0, :]
    show(io, subdf)
    show(io, subdf, true)
    showall(io, subdf)
    showall(io, subdf, true)

    if VERSION > v"0.5-"
        using Juno
        out = DataTables._render(df)
        @assert out.head.xs[1] == DataTable
        @assert isa(out.children()[1], Juno.Table)
        @assert size(out.children()[1].xs) == (4, 2)
    end

    dfvec = DataTable[df for _=1:3]
    show(io, dfvec)
    showall(io, dfvec)

    gd = groupby(df, :A)
    show(io, gd)
    showall(io, gd)

    dfr = DataTableRow(df, 1)
    show(io, dfr)

    df = DataTable(A = Array(String, 3))

    A = DataTables.StackedVector(Any[[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    show(io, A)
    A = DataTables.RepeatedVector([1, 2, 3], 5, 1)
    show(io, A)
    A = DataTables.RepeatedVector([1, 2, 3], 1, 5)
    show(io, A)

    #Test show output for REPL and similar
    df = DataTable(Fish = ["Suzy", "Amir"], Mass = [1.5, Nullable()])
    io = IOBuffer()
    show(io, df)
    str = String(take!(io))
    @test str == """
    2×2 DataTables.DataTable
    │ Row │ Fish │ Mass  │
    ├─────┼──────┼───────┤
    │ 1   │ Suzy │ 1.5   │
    │ 2   │ Amir │ #NULL │"""

    # Test computing width for Array{String} columns
    df = DataTable(Any[["a"]], [:x])
    io = IOBuffer()
    show(io, df)
    str = String(take!(io))
    @test str == """
    1×1 DataTables.DataTable
    │ Row │ x │
    ├─────┼───┤
    │ 1   │ a │"""
end
