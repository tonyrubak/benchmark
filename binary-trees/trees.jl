using Distributed
using MemoryArena

@everywhere include("tree_worker_arena.jl")

function run_benchmark(max_depth)
    min_depth = 4
    max_depth = min_depth + 2 > max_depth ? min_depth + 2 : max_depth

    stretch_depth = max_depth + 1

    arena = TypedArena{TreeNode}()

    println("stretch tree of depth $stretch_depth\t check: $(make_check((0,stretch_depth), arena))")

    long_lived_tree = create_tree(max_depth, arena)

    mmd = max_depth + min_depth
    for d in range(min_depth, step = 2, stop = max_depth)
        ntrees = 2 ^ (mmd - d)
        cs = @distributed (+) for chunk in get_argchunks(ntrees, d)
            worker_make_check(chunk)
        end
        println("$ntrees trees of depth $d\t check: $cs")
    end

    println("long lived tree of depth $max_depth\t check: $(check_tree(long_lived_tree))")
    destroy(arena)
end
