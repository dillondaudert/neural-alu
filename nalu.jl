# structs and methods for basic neural accumulator / neural arithmetic
# logic unit.

using Flux


# Neural Accumulator
mutable struct NAC{S}
    Ŵ::S
    M̂::S
    W::Union{S, Nothing}
    stale::Bool
end

NAC(in::Integer, out::Integer; initW = randn) = 
    NAC(param(initW(out, in)), param(initW(out, in)), nothing, true)

function (nac::NAC)(x; force_refresh=false)
    if force_refresh || nac.stale
        nac.W = tanh.(nac.Ŵ) .* σ.(nac.M̂)
        nac.stale = false
    end
    nac.W * x
end


# Neural Arithmetic Logic Unit
struct NALU{S}
    nacₐ::NAC
    nacₘ::NAC
    G::S
end

NALU(in::Integer, out::Integer) = 
    NALU(NAC(in, out), NAC(in, out), param(randn(out, in)))

function (nalu::NALU)(x; force_refresh=false)
    # gate
    g = σ.(nalu.G*x)
    
    # addition
    a = nalu.nacₐ(x, force_refresh=force_refresh)
    
    # multiplication
    m = exp.(nalu.nacₘ(log.(abs.(x) .+ eps()), force_refresh=force_refresh))
    
    # nalu
    return g .* a + (1 .- g) .* m
end

Flux.@treelike(NAC)
Flux.@treelike(NALU)