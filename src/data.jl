# Helper functions for generating train/test data

using Random

# 1. generate random input vectors
# 2. calculate a, b by summing regular elements of input
# 3. calculate target by performing the specific operation on a, b

"""
Generates training and test data for binary operations.

The test datasets have 20% of the number of samples as the
training dataset.

Two test datasets are created, one for interpolation and 
another for extrapolation. For the interpolation test data,
none of `a`, `b`, or `y` will be out of the range seen 
during training.

For the extrapolation test data, at least one of `a` or `b` 
will be outside the range seen during training.
"""
function gen_data(bin_op,
                  num_samples::Integer,
                  input_size::Integer,
                  mgn::Integer,
                  test_mgn::Integer,
                  perm=nothing
                 )
    if perm === nothing
        perm = randperm(input_size)
    end
    train_xs = [rand(input_size) .* (2*mgn) .- mgn for _ in 1:num_samples]
    train_ys = [bin_op(sum(x[perm[1:div(input_size, 2)]]), sum(x[perm[div(input_size, 2)+1:end]])) for x in train_xs]
    
    interp_xs = [rand(input_size) .* (2*mgn) .- mgn for _ in 1:div(num_samples, 5)]
    interp_ys = [bin_op(sum(x[perm[1:div(input_size, 2)]]), sum(x[perm[div(input_size, 2)+1:end]])) for x in interp_xs]
    
    extrap_xs = [rand(input_size) .* (2*test_mgn) .- test_mgn for _ in 1:div(num_samples, 5)]
    extrap_ys = [bin_op(sum(x[perm[1:div(input_size, 2)]]), sum(x[perm[div(input_size, 2)+1:end]])) for x in extrap_xs]
    
    return collect(zip(train_xs, train_ys)), collect(zip(interp_xs, interp_ys)), collect(zip(extrap_xs, extrap_ys)), perm
end