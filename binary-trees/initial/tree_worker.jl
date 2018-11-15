abstract type AbstractTree end

struct EmptyTree <: AbstractTree end

struct TreeNode <: AbstractTree
    left::AbstractTree
    right::AbstractTree
end

function create_tree(depth)
    if depth == 0
        TreeNode(EmptyTree(), EmptyTree())
    else
        depth = depth - 1
        TreeNode(create_tree(depth), create_tree(depth))
    end
end

function check_tree(tree)
    if typeof(tree.left) === EmptyTree
        1
    else
        1 + check_tree(tree.left) + check_tree(tree.right)
    end
end

function make_check(itde)
    i, depth = itde
    check_tree(create_tree(depth))
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
    cs = 0
    for pair in chunk
        cs += make_check(pair)
    end
    cs
end
