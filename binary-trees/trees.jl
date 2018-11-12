using Distributed
@everywhere abstract type AbstractTree end

@everywhere struct EmptyTree <: AbstractTree end

@everywhere struct TreeNode <: AbstractTree
    left::AbstractTree
    right::AbstractTree
end

@everywhere function create_tree(depth)
    if depth == 0
        TreeNode(EmptyTree(), EmptyTree())
    else
        depth = depth - 1
        TreeNode(create_tree(depth), create_tree(depth))
    end
end

@everywhere function check_tree(tree)
    if typeof(tree.left) === EmptyTree
        1
    else
        1 + check_tree(tree.left) + check_tree(tree.right)
    end
end

@everywhere function make_check(itde)
    i, depth = itde
    check_tree(create_tree(depth))
end

@everywhere function get_argchunks(i, d, chunksize = 5000)
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

@everywhere function worker_make_check(chunk)
    cs = 0
    for pair in chunk
        cs += make_check(pair)
    end
    cs
end

@everywhere function run_benchmark(max_depth)
    min_depth = 4
    max_depth = min_depth + 2 > max_depth ? min_depth + 2 : max_depth

    stretch_depth = max_depth + 1

    println("stretch tree of depth $stretch_depth\t check: $(make_check((0,stretch_depth)))")

    long_lived_tree = create_tree(max_depth)

    mmd = max_depth + min_depth
    for d in range(min_depth, step = 2, stop = max_depth)
        ntrees = 2 ^ (mmd - d)
        cs = @distributed (+) for chunk in get_argchunks(ntrees, d)
            worker_make_check(chunk)
        end
        println("$ntrees trees of depth $d\t check: $cs")
    end

    println("long lived tree of depth $max_depth\t check: $(check_tree(long_lived_tree))")
end
