# Helper functions for generating train/test data

# 1. generate random input vectors
# 2. calculate a, b by summing regular elements of input
# 3. calculate target by performing the specific operation on a, b

"""
Generates training and test data for a numeric function task.

Two test datasets are created, one for interpolation and 
another for extrapolation. For the extrapolation test data,
at least one of `a` or `b` will be 
"""
function gen_data(op,
                  num_samples::Integer,
                  input_size::Integer,
                  (min_val, max_val),
                  (test_min_val, test_max_val),
                 )
    train_data = [()]
    
end