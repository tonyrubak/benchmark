using MemoryArena
struct EmptyTree end

struct TreeNode
    left::RefCell{TreeNode}
    right::RefCell{TreeNode}
end

function create_tree(depth, arena)
    if depth == 0
        alloc(arena, TreeNode(RefCell{TreeNode}(nothing), RefCell{TreeNode}(nothing)))
    else
        depth = depth - 1
        alloc(arena, TreeNode(create_tree(depth, arena),
                              create_tree(depth, arena)))
    end
end

function check_tree(tree)
    tree = tree[]
    if tree === nothing
        throw(ErrorException("Null tree"))
    elseif tree.left[] === nothing
        1
    else
        1 + check_tree(tree.left) + check_tree(tree.right)
    end
end

function make_check(itde, arena)
    i, depth = itde
    check_tree(create_tree(depth, arena))
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
    arena = TypedArena{TreeNode}(UInt64(100000))
    cs = 0
    for pair in chunk
        cs += make_check(pair, arena)
    end
    destroy(arena)
    cs
end
