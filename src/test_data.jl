using Test

include("data.jl")

@testset "binary_data tests" begin
    input_size = 10
    perm = collect(1:10)
    
    for op in [+, -, *, /]
        (xs, ys), (_, a_inds, b_inds, abs) = binary_data(op, 100, input_size, 5, perm)
        for i in 1:length(xs)
            @test sum(xs[i][1:5]) == abs[i][1]
            @test sum(xs[i][6:10]) == abs[i][2]
            @test op(sum(xs[i][1:5]), sum(xs[i][6:10])) == ys[i]
        end
    end
end

@testset "unary_data tests" begin
    input_size = 10
    perm = collect(1:10)
    
    sqr(x) = ^(x, 2)
    
    for op in [sqr, sqrt]
        (xs, ys), (_, a_inds, b_inds, abs) = unary_data(op, 100, input_size, 5, perm)
        for i in 1:length(xs)
            @test sum(xs[i][1:5]) == abs[i][1]
            @test sum(xs[i][6:10]) == abs[i][2]
            @test op(sum(xs[i][1:5])) == ys[i]
        end
    end
end