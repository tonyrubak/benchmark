# benchmarks

Stuff from The Computer Language Benchmarks Game in Julia

## nbody.jl
```bash
~/benchmark_reference$ time ./nbody.gcc-4.gcc_run 50000000
-0.169075164
-0.169059907

real	0m3.030s
user	0m3.026s
sys	0m0.004s
```
```julia
julia> @time run_sim(50000000)
-0.169075164
-0.169059907
  4.694161 seconds (100 allocations: 6.500 KiB)
```

## binary-trees/trees.jl
### C++ (GNU)
```bash
~/benchmark_reference/gpp$ time ./binarytrees.gpp-9.gpp_run 21
stretch tree of depth 22	 check: 8388607
2097152	 trees of depth 4	 check: 65011712
524288	 trees of depth 6	 check: 66584576
131072	 trees of depth 8	 check: 66977792
32768	 trees of depth 10	 check: 67076096
8192	 trees of depth 12	 check: 67100672
2048	 trees of depth 14	 check: 67106816
512	 trees of depth 16	 check: 67108352
128	 trees of depth 18	 check: 67108736
32	 trees of depth 20	 check: 67108832
long lived tree of depth 21	 check: 4194303

real	0m1.041s
user	0m5.661s
sys	0m0.110s
```
### Julia (default allocator)
```julia
julia> @time run_benchmark(21)
stretch tree of depth 22	 check: 8388607
2097152 trees of depth 4	 check: 65011712
524288 trees of depth 6	 check: 66584576
131072 trees of depth 8	 check: 66977792
32768 trees of depth 10	 check: 67076096
8192 trees of depth 12	 check: 67100672
2048 trees of depth 14	 check: 67106816
512 trees of depth 16	 check: 67108352
128 trees of depth 18	 check: 67108736
32 trees of depth 20	 check: 67108832
long lived tree of depth 21	 check: 4194303
 19.763691 seconds (12.87 M allocations: 441.212 MiB, 2.53% gc time)
```
### Julia (TypedArena allocator)
```julia
julia> @time run_benchmark(21)
stretch tree of depth 22	 check: 8388607
2097152 trees of depth 4	 check: 65011712
524288 trees of depth 6	 check: 66584576
131072 trees of depth 8	 check: 66977792
32768 trees of depth 10	 check: 67076096
8192 trees of depth 12	 check: 67100672
2048 trees of depth 14	 check: 67106816
512 trees of depth 16	 check: 67108352
128 trees of depth 18	 check: 67108736
32 trees of depth 20	 check: 67108832
long lived tree of depth 21	 check: 4194303
  5.346647 seconds (34.42 k allocations: 44.990 MiB, 0.24% gc time)
```
