module TestIndexing
    using Base.Test
    using DataFrames


    # FIXME: this file wasn't included in the tests and didn't pass before the port

    #
    # DataFrame indexing
    #

    df = DataFrame(A = 1:2, B = 3:4)

    row_indices = Any[1,
                      1:2,
                      [1, 2],
                      [true, true],
                      trues(2),
                      NullableArray([1, 2]),
                      NullableArray([true, true]),
                      Colon()]

    column_indices = Any[1,
                         1:2,
                         [1, 2],
                         [true, false],
                         trues(2),
                         NullableArray([1, 2]),
                         NullableArray([true, false]),
                         Colon()]

    #
    # getindex()
    #

    for column_index in column_indices
        df[column_index]
    end

    for row_index in row_indices
        for column_index in column_indices
            df[row_index, column_index]
        end
    end

    #
    # setindex!()
    #

    for column_index in column_indices
        df[column_index] = df[column_index]
    end

    for row_index in row_indices
        for column_index in column_indices
            df[row_index, column_index] = df[row_index, column_index]
        end
    end

    #
    # Broadcasting assignments
    #

    for column_index in column_indices
        df[column_index] = Nullable()
        df[column_index] = 1
        df[column_index] = 1.0
        df[column_index] = "A"
        df[column_index] = NullableArray([1 + 0im, 2 + 1im])
    end

    # Only assign into columns for which new value is type compatible
    for row_index in row_indices
        for column_index in column_indices
            df[row_index, column_index] = Nullable()
            df[row_index, column_index] = 1
            df[row_index, column_index] = 1.0
            df[row_index, column_index] = "A"
            df[row_index, column_index] = NullableArray([1 + 0im, 2 + 1im])
        end
    end
end
