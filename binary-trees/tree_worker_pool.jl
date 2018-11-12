abstract type AbstractTree end

mutable struct EmptyTree <: AbstractTree end

mutable struct TreeNode <: AbstractTree
    left::Ptr{TreeNode}
    right::Ptr{TreeNode}
end

function create_tree(depth, pool)
    treeptr = alloc(pool)
    if depth == 0
        unsafe_store!(treeptr, TreeNode(C_NULL, C_NULL))
    else
        depth = depth - 1
        unsafe_store!(treeptr, TreeNode(create_tree(depth, pool),
                                        create_tree(depth, pool)))
    end
    treeptr
end

function check_tree(treeptr)
    tree = unsafe_load(treeptr)
    if tree.left == C_NULL
        1
    else
        1 + check_tree(tree.left) + check_tree(tree.right)
    end
end

function make_check(itde, pool)
    i, depth = itde
    check_tree(create_tree(depth, pool))
end

function get_argchunks(i, d, chunksize = 5000)
    @assert chunksize % 2 == 0
    num_chunks = i % chunksize == 0 ? div(i, chunksize) :
        div(i, chunksize) + 1
    chunks = Array{Array{Tuple{Int64,Int64}}}(undef, num_chunks)
    for j in 1:num_chunks-1
        chunk = Array{Tuple{Int64, Int64}}(undef, chunksize)
        for k in 1:chunksize
            @inbounds chunk[k] = (k + chunksize*(j-1), d)
        end
        chunks[j] = chunk
    end
        
    chunk = Array{Tuple{Int64, Int64}}(undef, i % chunksize)
    for j in 1:(i % chunksize)
        @inbounds chunk[j] = (j + chunksize*(num_chunks-1), d)
    end
    chunks[num_chunks] = chunk
    chunks
end

function worker_make_check(chunk)
    pool = Pool(300000000, TreeNode)
    cs = 0
    for pair in chunk
        cs += make_check(pair, pool)
    end
    destroy(pool)
    cs
end
