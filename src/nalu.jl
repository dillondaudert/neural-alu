# structs and methods for basic neural accumulator / neural arithmetic
# logic unit.


# - Neural Accumulator - #
"""
A linear layer whose weights are soft constrained to be near one of
{-1, 0, 1}. The weights are calculated by tanh.(W) .* σ.(M).
"""
struct NeuralAccumulator{R <: AbstractMatrix}
    W::R
    M::R
    function NeuralAccumulator{R}(w, m) where {R <: AbstractMatrix}
        size(w) == size(m) || error("sizes of weight matrices must match")
        new{R}(w, m)
    end
end
NeuralAccumulator(W::R, M::R) where {R <: AbstractMatrix} = NeuralAccumulator{R}(W, M)

function NeuralAccumulator(::Type{T}, in::Integer, out::Integer, init_fn) where {T <: Number}
    return NeuralAccumulator(init_fn(T, out, in), init_fn(T, out, in))
end

NeuralAccumulator(in::Integer, out::Integer, init_fn=randn) = NeuralAccumulator(Float64, in, out, init_fn)

operator(nac::NeuralAccumulator) = (2 .* σ.(nac.W) .- 1) .* σ.(nac.M)

(nac::NeuralAccumulator)(x) = operator(nac) * x



# - Neural Arithmetic Logic Unit - #
struct NeuralALU{R <: AbstractMatrix}
    nac::NeuralAccumulator{R}
    G::R
    b
end

NALU(in::Integer, out::Integer; initW = Flux.initn, initb = zeros) =
    NALU(NAC(in, out, initW=initW), param(initW(out, in)), param(initb(out)))

Flux.@treelike(NALU)

function (nalu::NALU)(x)
    # gate
    g = σ_stable.(nalu.G*x .+ nalu.b)

    # addition
    a = nalu.nac(x)

    # multiplication
    m = exp.(nalu.nac(log.(abs.(x) .+ eps())))

    # nalu
    return g .* a + (1 .- g) .* m
end
