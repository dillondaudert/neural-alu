# Helper functions for generating train/test data

using Random

"""
Generates a dataset for binary operations.
"""
function binary_data(bin_op,
                     num_samples::Integer,
                     input_size::Integer,
                     mgn::Integer,
                     perm=nothing
                    )
    if perm === nothing
        perm = randperm(input_size)
    end
    a_inds = perm[1:div(input_size, 2)]
    b_inds = perm[div(input_size, 2)+1:end]
    
    data_xs = [rand(input_size) .* (2*mgn) .- mgn for _ in 1:num_samples]
    data_abs = [(sum(x[a_inds]), sum(x[b_inds])) for x in data_xs]
    data_ys = [bin_op(a, b) for (a, b) in data_abs]
    
    return (data_xs, data_ys), (perm, a_inds, b_inds, data_abs)
end

"""
Generates a dataset for unary operations.

Unlike the binary_data function, this does not generate
negative values.
"""
function unary_data(op,
                    num_samples::Integer,
                    input_size::Integer,
                    mgn::Integer,
                    perm=nothing
                    )
    if perm === nothing
        perm = randperm(input_size)
    end
    a_inds = perm[1:div(input_size, 2)]
    b_inds = perm[div(input_size, 2)+1:end]
    
    data_xs = [rand(input_size) .* (2*mgn) for _ in 1:num_samples]
    data_abs = [(sum(x[a_inds]), sum(x[b_inds])) for x in data_xs]
    data_ys = [op(a) for (a, _) in data_abs]
    
    return (data_xs, data_ys), (perm, a_inds, b_inds, data_abs)
end