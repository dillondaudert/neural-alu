# Helper functions for generating train/test data

using Random

"""
Generate random vectors with constrained magnitudes.

If a_inds (and optionally b_inds) is provided, then
the magnitude constraints will apply to the subset
of indices specified by these vectors.

Returns a single vector of values.
"""
function randmgn(input_size, min, max, a_inds, b_inds=nothing)
    while true
        sample = rand(input_size) .* 2*max .- max
        asum = sum(sample[a_inds])
        if b_inds !== nothing
            bsum = sum(sample[b_inds])
        end
        if asum < max && asum > min && (b_inds === nothing || (bsum < max && bsum > min))
            return sample
        end
    end
end

"""
Generates a dataset for binary operations.
"""
function binary_data(bin_op,
                     num_samples::Integer,
                     input_size::Integer,
                     mgn::Integer;
                     perm=nothing,
                     min_mgn=0,
                    )
    if perm === nothing
        perm = randperm(input_size)
    end
    a_inds = perm[1:div(input_size, 2)]
    b_inds = perm[div(input_size, 2)+1:end]
    
    data_xs = [randmgn(input_size, min_mgn, mgn, a_inds, b_inds) for _ in 1:num_samples]
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
                    perm=nothing,
                    min_mgn=0
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