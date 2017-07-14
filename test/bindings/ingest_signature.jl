import Mocking: Bindings, ingest_signature!

@test @valid_method f(x) = x
b = Bindings()
ingest_signature!(b, :(f(x) = x).args[1])
@test b.internal == Set([:f, :x])
@test b.external == Set()

@test @valid_method f{T}(::Type{T}) = T
b = Bindings()
ingest_signature!(b, :(f{T}(::Type{T}) = T).args[1])
@test b.internal == Set([:f, :T])
@test b.external == Set([:Type])

if VERSION >= v"0.6"
    @test @valid_method f{T,S<:T}(x::T, y::S) = (x, y)
end
b = Bindings()
ingest_signature!(b, :(f{T,S<:T}(x::T, y::S) = (x, y)).args[1])
@test b.internal == Set([:f, :T, :S, :x, :y])
@test b.external == Set()

@test @valid_method f(x=f) = x  # `f` the argument default refers the the function `f`
b = Bindings()
ingest_signature!(b, :(f(x=f)))
@test b.internal == Set([:f, :x])
@test b.external == Set()

@test @valid_method f(f) = f  # `f` the function and `f` the parameter variable
b = Bindings()
ingest_signature!(b, :(f(f)))
@test b.internal == Set([:f])  # Wrong? Technically there are two separate `f`s here
@test b.external == Set()

# f = 1; f(x=f) = f  # Error
