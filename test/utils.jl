module TestUtils
    using Base.Test, DataTables, Nulls, StatsBase
    import DataTables: identifier

    @test identifier("%_B*_\tC*") == :_B_C_
    @test identifier("2a") == :x2a
    @test identifier("!") == :x!
    @test identifier("\t_*") == :_
    @test identifier("begin") == :_begin
    @test identifier("end") == :_end

    @test DataTables.make_unique([:x, :x, :x_1, :x2]) == [:x, :x_2, :x_1, :x2]
    @test_throws ArgumentError DataTables.make_unique([:x, :x, :x_1, :x2], allow_duplicates=false)
    @test DataTables.make_unique([:x, :x_1, :x2], allow_duplicates=false) == [:x, :x_1, :x2]

    # Check that reserved words are up to date
    f = "$JULIA_HOME/../../src/julia-parser.scm"
    if isfile(f)
        if VERSION >= v"0.5.0-dev+3678"
            r1 = r"define initial-reserved-words '\(([^)]+)"
        else
            r1 = r"define reserved-words '\(([^)]+)"
        end
        r2 = r"define \(parse-block s(?: \([^)]+\))?\)\s+\(parse-Nary s (?:parse-eq '\([^(]*|down '\([^)]+\) '[^']+ ')\(([^)]+)"
        body = readstring(f)
        m1, m2 = match(r1, body), match(r2, body)
        if m1 == nothing || m2 == nothing
            error("Unable to extract keywords from 'julia-parser.scm'.")
        else
            s = replace(m1.captures[1]*" "*m2.captures[1], r";;.*?\n", "")
            rw = Set(split(s, r"\W+"))
            @test rw == DataTables.RESERVED_WORDS
        end
    else
        warn("Unable to validate reserved words against parser. ",
             "Expected if Julia was not built from source.")
    end

    @test DataTables.countnull([1:3;]) == 0

    data = Vector{?Float64}(rand(20))
    @test DataTables.countnull(data) == 0
    data[sample(1:20, 11, replace=false)] = null
    @test DataTables.countnull(data) == 11
    data[1:end] = null
    @test DataTables.countnull(data) == 20

    pdata = Vector{?Int}(sample(1:5, 20))
    @test DataTables.countnull(pdata) == 0
    pdata[sample(1:20, 11, replace=false)] = null
    @test DataTables.countnull(pdata) == 11
    pdata[1:end] = null
    @test DataTables.countnull(pdata) == 20

    funs = [mean, sum, var, x -> sum(x)]
    if string(funs[end]) == "(anonymous function)" # Julia < 0.5
        @test DataTables._fnames(funs) == ["mean", "sum", "var", "λ1"]
    else
        @test DataTables._fnames(funs) == ["mean", "sum", "var", string(funs[end])]
    end

    @testset "describe" begin
        io = IOBuffer()
        dt = DataTable(Any[collect(1:4), Vector{?Int}(2:5),
                           CategoricalArray(3:6),
                           NullableCategoricalArray(4:7)],
                       [:arr, :nullarr, :cat, :nullcat])
        describe(io, dt)
        @test String(take!(io)) ==
            """
            arr
            Summary Stats:
            Mean:           2.500000
            Minimum:        1.000000
            1st Quartile:   1.750000
            Median:         2.500000
            3rd Quartile:   3.250000
            Maximum:        4.000000
            Length:         4
            Type:           Int64

            nullarr
            Summary Stats:
            Length:         4
            Type:           Union{Int64, Nulls.Null}
            Number Unique:  4

            cat
            Summary Stats:
            Length:         4
            Type:           CategoricalArrays.CategoricalValue{Int64,UInt32}
            Number Unique:  4

            nullcat
            Summary Stats:
            Length:         4
            Type:           Union{CategoricalArrays.CategoricalValue{Int64,UInt32}, Nulls.Null}
            Number Unique:  4

            """
    end
end
