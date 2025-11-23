## 测试结果

1. CPU: Intel(R) Core(TM) i7-6700HQ CPU @ 2.60GHz
Run on (4 X 2592 MHz CPU s)
CPU Caches:
  L1 Data 32 KiB (x4)
  L1 Instruction 32 KiB (x4)
  L2 Unified 256 KiB (x4)
  L3 Unified 6144 KiB (x2)

-----------------------------------------------------------------
            Benchmark           Time             CPU   Iterations
-----------------------------------------------------------------
Before      bench1      872119518 ns    871758718 ns            3
After       bench1       64712738 ns     64694471 ns           41


2. CPU: 
Run on (2 X 2000 MHz CPU s)
CPU Caches:
  L1 Data 48 KiB (x2)
  L1 Instruction 32 KiB (x2)
  L2 Unified 2048 KiB (x2)
  L3 Unified 53760 KiB (x2)

3. CPU: 
Run on (72 X 2496.08 MHz CPU s)
CPU Caches:
  L1 Data 32 KiB (x72)
  L1 Instruction 32 KiB (x72)
  L2 Unified 1024 KiB (x72)
  L3 Unified 25344 KiB (x4)

Only a speed up of 24%

## 分析

```bash
$ toplev --core S0-C0 -l3 --no-desc taskset -c 0 ./lab ../pexels-pixabay-434334.pbm output.pbm
```

```
# 5.01-full-perf on Intel(R) Core(TM) i7-6700HQ CPU @ 2.60GHz [skl/skylake]
FE               Frontend_Bound.Fetch_Latency.MS_Switches       % Clocks_est                   0.9   [ 3.7%]
RET              Retiring.Heavy_Operations.Microcode_Sequencer  % Slots                        0.6   [ 3.7%]
BAD              Bad_Speculation.Machine_Clears                 % Slots                        0.3   [ 3.6%]
BE/Mem           Backend_Bound.Memory_Bound                     % Slots                       68.9   [ 3.7%]
BE               Backend_Bound                                  % Slots                       74.8   [ 3.7%]
BE/Mem           Backend_Bound.Memory_Bound.L1_Bound            % Stalls                      18.0   [ 3.6%]
BE/Mem           Backend_Bound.Memory_Bound.L3_Bound            % Stalls                      36.9   [ 3.6%]<==
MUX                                                             %                              3.47 
Run toplev --describe L3_Bound^ to get more information on bottleneck
Add --run-sample to find locations
Add --nodes '!+L3_Bound*/4,+MUX' for breakdown.
```

由于主要瓶颈在于 L3 cache miss，也就是说需要不断从内存取数据。
如果 CPU 的 L3 cache 的大小提高，性能就能得到直接提高。
这解释了为什么第 2 和 第 3 个 CPU 上，未改进的代码就能得到比较好的性能，以至于优化提升没有第一个 CPU 上明显。
当然，如果程序的数据量进一步提高，代码优化提升将变得十分有意义。
