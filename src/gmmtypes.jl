## gmm/types.jl  The type that implements a GMM. 
## (c) 2013--2014 David A. van Leeuwen

## Some remarks on the dimension.  There are three main indexing variables:
## - The gaussian index 
## - The data point
## - The feature dimension
## Often data is stores in 2D arrays, and computations can be done efficiently in 
## matrix multiplications.  For this it is nice to have the data in standard row,column order
## however, we can't have these consistently over all three indexes. 

## My approach is do have:
## - The data index (i) always be a row-index
## - The feature dimenssion index (k) always to be a column index
## - The Gaussian index (j) to be mixed, depending on how it is used

## force Emacs utf-8: αβγδεζηθικλμνξοπρστυφχψω 

type History
    t::Float64
    s::String
end
History(s::String) = History(time(), s)

type GMM
    n::Int                      # number of Gaussians
    d::Int                      # dimension of Gaussian
    kind::Symbol                # :diag or :full---we'll take 'diag' for now
    w::Vector{Float64}          # weights: n
    μ::Array{Float64}		# means: n x d
    Σ::Array{Float64}           # covars n x d
    hist::Array{History}        # history
    function GMM(n::Int, d::Int, kind) 
        w = ones(n)/n
        μ = zeros(n, d)
        Σ = ones(n, d)
        hist = {History(@sprintf "Initialization n=%d, d=%d, kind=%s" n d kind)}
        new(n, d, kind, w, μ, Σ, hist)
    end
end
GMM(n::Int,d::Int) = GMM(n,d, :diag)

## UBM-centered stats.  This structure currently is useful for dotscoring, so we've limited the
## order to 1.  Maybe we can make this more general allowing for uninitialized second order
## stats?

## We store the stats in a (ng * d) structure, i.e., not as a super vector yet.  
## Perhaps in ivector processing a supervector is easier. 
type Cstats
    n::Vector{Float64}          # zero-order stats, ng
    f::Array{Float64,2}          # second-order stats, ng * d
    function Cstats(n::Vector{Float64}, f::Array{Float64,2})
        @assert size(n,1)==size(f, 1)
        new(n,f)
    end
end
## Cstats(n::Array{Float64,2}, f::Array{Float64,2}) = Cstats(reshape(n, prod(size(n))), reshape(f, prod(size(f))))
Cstats(t::Tuple) = Cstats(t[1], t[2])

## A data handle, either in memory or on disk, perhaps even mmapped but I haven't seen any 
## advantage of that.  It contains a list of either files (where the data is stored)
## or data units.  The point is, that in processing, these units can naturally be processed
## independently.  
type Data{T}
    datatype::Type
    list::Vector
    read::Union(Function,Nothing)
    Data{T}(list::Vector, read::Union(Function,Nothing)) = new(T,list,read)
end

typealias DataOrMatrix{T<:FloatingPoint} Union(Data{T}, Matrix{T})
