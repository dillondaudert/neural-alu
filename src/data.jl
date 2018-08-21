# Helper functions for generating train/test data

using Random

function batch_dataset((xs, ys), batch_size)
    if length(xs) % batch_size != 0
        error("batch_size must evenly divide dataset")
    end
    batch_xs = [hcat(xs[(i-1)*batch_size+1:i*batch_size]...) for i = 1:div(length(xs), batch_size)]
    batch_ys = [hcat(ys[(i-1)*batch_size+1:i*batch_size]...) for i = 1:div(length(xs), batch_size)]
    return (batch_xs, batch_ys)
end

"""
Generate random vectors with constrained magnitudes.

If a_inds (and optionally b_inds) is provided, then
the magnitude constraints will apply to the subset
of indices specified by these vectors.

Returns a single vector of values.
"""
function randmgn(op, input_size, min, max, a_inds, b_inds=nothing)
    if max < min
        error("min should be less than max in randmgn!")
    end
    if op(min, min) >= max
        error("$op(min, min) results in a value greater than max! min: $min, max: $max")
    end
    while true
        sample = rand(input_size) .* 2*max .- max
        a = sum(sample[a_inds])
        aabs = abs(a)
        if b_inds !== nothing
            b = sum(sample[b_inds])
            babs = abs(b)
            yabs = abs(op(a, b))
        else
            yabs = abs(op(a))
        end
        if aabs < max && aabs > min && (b_inds === nothing || (babs < max && babs > min)) && yabs < max && yabs > min
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
                     max::Integer;
                     perm=nothing,
                     min=0,
                    )
    if perm === nothing
        perm = randperm(input_size)
    end
    a_inds = perm[1:div(input_size, 2)]
    b_inds = perm[div(input_size, 2)+1:end]
    
    data_xs = [randmgn(bin_op, input_size, min, max, a_inds, b_inds) for _ in 1:num_samples]
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
                    max::Integer,
                    perm=nothing,
                    min=0
                    )
    if perm === nothing
        perm = randperm(input_size)
    end
    a_inds = perm[1:div(input_size, 2)]
    b_inds = perm[div(input_size, 2)+1:end]
    
    data_xs = [rand(input_size) .* (2*max) for _ in 1:num_samples]
    data_abs = [(sum(x[a_inds]), sum(x[b_inds])) for x in data_xs]
    data_ys = [op(a) for (a, _) in data_abs]
    
    return (data_xs, data_ys), (perm, a_inds, b_inds, data_abs)
end