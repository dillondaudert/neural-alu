# structs and methods for basic neural accumulator / neural arithmetic
# logic unit.

using Flux


# - Neural Accumulator - #
mutable struct NAC{S}
    Ŵ::S
    M̂::S
    W::Union{S, Nothing}
end

NAC(in::Integer, out::Integer; initW = randn) = 
    NAC(param(initW(out, in)), param(initW(out, in)), nothing)

function (nac::NAC)(x)
    nac.W = tanh.(nac.Ŵ) .* σ.(nac.M̂)
    nac.W * x
end

Flux.@treelike(NAC)


# - Neural Arithmetic Logic Unit - #
struct NALU{S}
    nacₐ::NAC
    nacₘ::NAC
    G::S
end

NALU(in::Integer, out::Integer) = 
    NALU(NAC(in, out), NAC(in, out), param(randn(out, in)))

function (nalu::NALU)(x)
    # gate
    g = σ.(nalu.G*x)
    
    # addition
    a = nalu.nacₐ(x)
    
    # multiplication
    m = exp.(nalu.nacₘ(log.(abs.(x) .+ eps())))
    
    # nalu
    return g .* a + (1 .- g) .* m
end

Flux.@treelike(NALU)