module LuxDeviceUtilsMetalExt

using ChainRulesCore, LuxDeviceUtils, Metal, Random
import Adapt: adapt_storage, adapt
import ChainRulesCore as CRC

function __init__()
    LuxDeviceUtils.ACCELERATOR_STATE_CHANGED[] = true
    return
end

# Device Transfer
## To GPU
adapt_storage(::LuxMetalAdaptor, x) = adapt_storage(Metal.MtlArrayAdaptor(), x)
adapt_storage(::LuxMetalAdaptor, rng::AbstractRNG) = rng

## Chain Rules
CRC.rrule(::Type{Array}, x::MtlArray) = Array(x), Δ -> (NoTangent(), MtlArray(Δ))

function CRC.rrule(::typeof(adapt_storage), to::LuxCPUAdaptor, x::MtlArray)
    function ∇adapt_storage(Δ)
        return (NoTangent(), NoTangent(), adapt_storage(LuxMetalAdaptor(), Δ))
    end
    return adapt_storage(to, x), ∇adapt_storage
end

function CRC.rrule(::typeof(adapt_storage), to::LuxMetalAdaptor, x::Array)
    function ∇adapt_storage(Δ)
        return (NoTangent(), NoTangent(), adapt_storage(LuxCPUAdaptor(), Δ))
    end
    return adapt_storage(to, x), ∇adapt_storage
end

end