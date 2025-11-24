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

注：与 L1/L2 不同，L3 显示的 "x2" 表示是两个 slice ，但是总 size 还是只有 6 MB.


2. CPU: 11th Gen Intel(R) Core(TM) i7-1185G7 @ 3.00GHz
Run on (8 X 2995 MHz CPU s)
CPU Caches:
  L1 Data 128 KiB (x4)
  L1 Instruction 192 KiB (x4)
  L2 Unified 5120 KiB (x4)
  L3 Unified 12288 KiB (x)
-----------------------------------------------------------------
            Benchmark           Time             CPU   Iterations
-----------------------------------------------------------------
Before      bench1      401858871 ns    343750000 ns            7
After       bench1       38848359 ns     30330882 ns           85


3. CPU: Intel(R) Xeon(R) Gold 6254 CPU @ 3.10GHz
Run on (72 X 3900.09 MHz CPU s)
CPU Caches:
  L1 Data 32 KiB (x72)
  L1 Instruction 32 KiB (x72)
  L2 Unified 1024 KiB (x72)
  L3 Unified 25344 KiB (x4)
-----------------------------------------------------------------
            Benchmark           Time             CPU   Iterations
-----------------------------------------------------------------
Before      bench1      113563637 ns    113235357 ns           25
After       bench1       71000411 ns     70824550 ns           39


4. CPU: Intel(R) Xeon(R) Gold 5420+
Run on (2 X 2000 MHz CPU s)
CPU Caches:
  L1 Data 48 KiB (x2)
  L1 Instruction 32 KiB (x2)
  L2 Unified 2048 KiB (x2)
  L3 Unified 53760 KiB (x2)
-----------------------------------------------------------------
            Benchmark           Time             CPU   Iterations
-----------------------------------------------------------------
Before      bench1      134268126 ns    132857561 ns           21
After       bench1       67787686 ns     66834258 ns           43


5. CPU: Intel(R) Xeon(R) Platinum 8380 CPU @ 2.30GHz
Run on (80 X 954.229 MHz CPU s)
CPU Caches:
  L1 Data 48 KiB (x80)
  L1 Instruction 32 KiB (x80)
  L2 Unified 1280 KiB (x80)
  L3 Unified 61440 KiB (x2)
-----------------------------------------------------------------
            Benchmark           Time             CPU   Iterations
-----------------------------------------------------------------
Before      bench1       97552738 ns     97380941 ns           29
After       bench1       61218195 ns     61097858 ns           45


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

优化前：

```cpp
for (int c = 0; c < width; c++) {
  for (int r = radius; r < height - radius; r++) {
    for (int i = 0; i < radius + 1 + radius; i++) {
      dot += input[(r - radius + i) * width + c] * kernel[i];
    }
  }
}
```
其中，`height=4306 width=6856 radius=2`，缓存 `input[(r - radius + i) * width + c]` 大概需要 `radius * width = 53 KB` 的空间，
当 CPU L3 cache 增长到 53 MB 时，就可以缓存 1000 个 input 数据，所以 CPU 升级后的提升没有之前的明显。
