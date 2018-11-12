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
  5.175074 seconds (100 allocations: 6.500 KiB)
```
