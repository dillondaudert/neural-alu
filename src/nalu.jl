# structs and methods for basic neural accumulator / neural arithmetic
# logic unit.

using Flux
using NNlib: σ_stable


# - Neural Accumulator - #
struct NAC{S}
    Ŵ::S
    M̂::S
end

NAC(in::Integer, out::Integer; initW = Flux.initn) = 
    NAC(param(initW(out, in)), param(initW(out, in)))

Flux.@treelike(NAC)

function (nac::NAC)(x)
    W = tanh.(nac.Ŵ) .* σ_stable.(nac.M̂)
    return W * x
end



# - Neural Arithmetic Logic Unit - #
struct NALU{S, T}
    nac::NAC
    G::S
    b::T
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
