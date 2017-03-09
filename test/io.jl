module TestIO
    using Base.Test
    using DataTables
    using LaTeXStrings
    using NullableArrays
    using CategoricalArrays

    # Test LaTeX export
    dt = DataTable(A = 1:4,
                   B = ["\$10.0", "M&F", "A~B", "\\alpha"],
                   C = [L"\alpha", L"\beta", L"\gamma", L"\sum_{i=1}^n \delta_i"],
                   D = [1.0, 2.0, Nullable(), 3.0]
                   )
    str = """
        \\begin{tabular}{r|cccc}
        \t& A & B & C & D\\\\
        \t\\hline
        \t1 & 1 & \\\$10.0 & \$\\alpha\$ & 1.0 \\\\
        \t2 & 2 & M\\&F & \$\\beta\$ & 2.0 \\\\
        \t3 & 3 & A\\textasciitilde{}B & \$\\gamma\$ &  \\\\
        \t4 & 4 & \\textbackslash{}alpha & \$\\sum_{i=1}^n \\delta_i\$ & 3.0 \\\\
        \\end{tabular}
        """
    @test reprmime(MIME("text/latex"), dt) == str

    #Test HTML output for IJulia and similar
    dt = DataTable(Fish = ["Suzy", "Amir"], Mass = [1.5, Nullable()])
    io = IOBuffer()
    show(io, "text/html", dt)
    str = String(take!(io))
    @test str == "<table class=\"data-frame\"><tr><th></th><th>Fish</th><th>Mass</th></tr><tr><th>1</th><td>Suzy</td><td>1.5</td></tr><tr><th>2</th><td>Amir</td><td>#NULL</td></tr></table>"

    # test limit attribute of IOContext is used
    dt = DataTable(a=collect(1:1000))
    ioc = IOContext(IOBuffer(), displaysize=(10, 10), limit=false)
    show(ioc, "text/html", dt)
    @test length(String(take!(ioc.io))) > 10000

    io = IOBuffer()
    show(io, "text/html", dt)
    @test length(String(take!(io))) < 10000

    dt = DataTable(A = 1:26,
                   B = 'a':'z',
                   C = [string(x) for x='A':'Z'],
                   D = CategoricalArray([string(x) for x='A':'Z']),
                   E = NullableArray(rand(26)),
                   F = NullableArray(fill(Nullable(), 26)),
                   G = fill(Nullable(), 26))

    answer = Sys.WORD_SIZE == 64 ? 0xde54e70f51205910 : 0x340524cd
    @test hash(sprint(printtable, dt)) == answer
end
