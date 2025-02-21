"""
    bitarray_to_index(bits::BitArray) -> Int

Convert a BitArray to its corresponding integer index.
"""
function bitarray_to_index(bits::BitArray)
	return foldl((acc, b) -> acc * 2 + b, bits, init = 0) + 1
end

"""
    index_to_bitarray(value::Int, n::Int) -> BitArray

Convert an integer index to its corresponding BitArray representation with `n` bits.
"""
function index_to_bitarray(value::Int, n::Int)
    @assert value >= 1 && value <= 2^n
	bits = reverse(digits(value - 1, base = 2))
	return BitArray(vcat(zeros(Int, n - length(bits)), bits))
end