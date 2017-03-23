module TestDuplicates
    using Base.Test
    using DataTables

    dt = DataTable(a = [1, 2, 3, 3, 4])
    udt = DataTable(a = [1, 2, 3, 4])
    @test isequal(.!isunique(dt, 1), [false, false, false, true, false])
    @test isequal(udt, unique(dt))
    unique!(dt)
    @test isequal(dt, udt)

    pdt = DataTable(a = NullableCategoricalArray(Nullable{String}["a", "a", Nullable(),
                                             Nullable(), "b", Nullable(), "a", Nullable()]),
                    b = NullableCategoricalArray(Nullable{String}["a", "b", Nullable(),
                                                              Nullable(), "b", "a", "a", "a"]))
    updt = DataTable(a = NullableCategoricalArray(Nullable{String}["a", "a", Nullable(), "b", Nullable()]),
                     b = NullableCategoricalArray(Nullable{String}["a", "b", Nullable(), "b", "a"]))
    @test isequal(.!isunique(pdt, 1), [false, false, false, true, false, false, true, true])
    @test isequal(.!isunique(updt, 1), falses(5))
    @test isequal(updt, unique(pdt))
    unique!(pdt)
    @test isequal(pdt, updt)
end
