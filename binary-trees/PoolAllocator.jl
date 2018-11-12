mutable struct Pool{T}
    ptr::Ptr{Nothing}
    sz::UInt64
    capacity::UInt64
    next::UInt64
end

function Pool(capacity, T)
    sz = UInt64(sizeof(T))
    capacity = UInt64(capacity)
    ptr = Libc.malloc(sz*capacity)
    @assert ptr != C_NULL
    Pool{T}(ptr, sz, capacity, 0x000000000)
end

function destroy(pool)
    Libc.free(pool.ptr)
end

function alloc(pool::Pool{T}) where {T}
    @assert pool.next < pool.capacity
    objptr = pool.ptr + pool.next
    pool.next += pool.sz
    convert(Ptr{T}, objptr)
end
