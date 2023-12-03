real(z::GaussMod{N}) where {N} = real(value(z))
imag(z::GaussMod{N}) where {N} = imag(value(z))
conj(z::GaussMod{N}) where {N} = GaussMod{N}(real(z), -imag(z))


(+)(x::GaussMod{N}, y::GaussMod{N}) where {N} = GaussMod{N}(x.val + y.val)
