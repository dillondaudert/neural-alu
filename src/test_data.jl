using Test

include("data.jl")

@testset "fixed binary_data tests" begin
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

@testset "random binary_data tests" begin
    input_size = 20
    
    for op in [+, -, *, /]
        (xs, ys), (perm, a_inds, b_inds, abs) = binary_data(op, 100, input_size, 10)
        (xs2, ys2), (perm2, a_inds2, b_inds2, abs2) = binary_data(op, 100, input_size, 10, perm)
        
        @test all(perm .== perm2)
        @test all(a_inds .== a_inds2)
        @test all(b_inds .== b_inds2)
                
        @testset "random perm check" begin
            for i in 1:length(xs)
                @test sum(xs[i][a_inds]) == abs[i][1]
                @test sum(xs[i][b_inds]) == abs[i][2]
                @test op(sum(xs[i][a_inds]), sum(xs[i][b_inds])) == ys[i]
            end
        end
        
        @testset "re-used perm check" begin
            for i in 1:length(xs2)
                @test sum(xs2[i][a_inds]) == abs2[i][1]
                @test sum(xs2[i][b_inds]) == abs2[i][2]
                @test op(sum(xs2[i][a_inds]), sum(xs2[i][b_inds])) == ys2[i]
            end
            
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