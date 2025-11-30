
## 结果

```bash
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cd build
cmake --build . --target benchmarkLab
```

--------------------------------------------------------------------------
        Benchmark                        Time             CPU   Iterations
--------------------------------------------------------------------------
Before  bench_compute_alignment    4148986 ns      4146617 ns          657
After   bench_compute_alignment     454165 ns       454059 ns         5750


## 优化前

```bash
$ clang++ -O3 -ffast-math -march=native -g -DNDEBUG -std=gnu++17 -o CMakeFiles/lab.dir/solution.cpp.o -c ../solution.cpp -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize
../solution.cpp:60:7: remark: loop not vectorized: value that could not be identified as reduction is used outside the loop [-Rpass-analysis=loop-vectorize]
   60 |       for (unsigned row = 1; row <= sequence1.size(); ++row) {
      |       ^
../solution.cpp:60:7: remark: loop not vectorized [-Rpass-missed=loop-vectorize]
../solution.cpp:44:5: remark: vectorized loop (vectorization width: 8, interleaved count: 2) [-Rpass=loop-vectorize]
   44 |     for (size_t i = 1; i < score_column.size(); ++i) {
      |     ^
```


## 优化后

```bash
$ clang++ -O3 -ffast-math -march=native -g -DNDEBUG -std=gnu++17 -o CMakeFiles/lab.dir/solution.cpp.o -c ../solution.cpp -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize
In file included from ../solution.cpp:1:
In file included from ../solution.hpp:1:
In file included from /usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/array:43:
/usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/bits/stl_algobase.h:919:11: remark: loop not vectorized: call instruction cannot be vectorized [-Rpass-analysis=loop-vectorize]
  919 |         *__first = __value;
      |                  ^
/usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/bits/stl_algobase.h:918:7: remark: loop not vectorized: instruction cannot be vectorized [-Rpass-analysis=loop-vectorize]
  918 |       for (; __first != __last; ++__first)
      |       ^
/usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/bits/stl_algobase.h:918:7: remark: loop not vectorized [-Rpass-missed=loop-vectorize]
../solution.cpp:14:5: remark: the cost-model indicates that interleaving is not beneficial [-Rpass-analysis=loop-vectorize]
   14 |     for (size_t j = 0; j < sequences[i].size(); ++j) {
      |     ^
../solution.cpp:14:5: remark: vectorized loop (vectorization width: 32, interleaved count: 1) [-Rpass=loop-vectorize]
In file included from ../solution.cpp:1:
In file included from ../solution.hpp:1:
In file included from /usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/array:43:
/usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/bits/stl_algobase.h:919:11: remark: loop not vectorized: call instruction cannot be vectorized [-Rpass-analysis=loop-vectorize]
  919 |         *__first = __value;
      |                  ^
/usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/bits/stl_algobase.h:918:7: remark: loop not vectorized: instruction cannot be vectorized [-Rpass-analysis=loop-vectorize]
  918 |       for (; __first != __last; ++__first)
      |       ^
/usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/bits/stl_algobase.h:918:7: remark: loop not vectorized [-Rpass-missed=loop-vectorize]
../solution.cpp:14:5: remark: the cost-model indicates that interleaving is not beneficial [-Rpass-analysis=loop-vectorize]
   14 |     for (size_t j = 0; j < sequences[i].size(); ++j) {
      |     ^
../solution.cpp:14:5: remark: vectorized loop (vectorization width: 32, interleaved count: 1) [-Rpass=loop-vectorize]
In file included from ../solution.cpp:1:
In file included from ../solution.hpp:1:
In file included from /usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/array:43:
/usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/bits/stl_algobase.h:919:11: remark: loop not vectorized: call instruction cannot be vectorized [-Rpass-analysis=loop-vectorize]
  919 |         *__first = __value;
      |                  ^
/usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/bits/stl_algobase.h:918:7: remark: loop not vectorized: instruction cannot be vectorized [-Rpass-analysis=loop-vectorize]
  918 |       for (; __first != __last; ++__first)
      |       ^
/usr/lib/gcc/x86_64-linux-gnu/13/../../../../include/c++/13/bits/stl_algobase.h:918:7: remark: loop not vectorized [-Rpass-missed=loop-vectorize]
../solution.cpp:14:5: remark: the cost-model indicates that interleaving is not beneficial [-Rpass-analysis=loop-vectorize]
   14 |     for (size_t j = 0; j < sequences[i].size(); ++j) {
      |     ^
../solution.cpp:14:5: remark: vectorized loop (vectorization width: 32, interleaved count: 1) [-Rpass=loop-vectorize]
../solution.cpp:62:3: remark: the cost-model indicates that vectorization is not beneficial [-Rpass-missed=loop-vectorize]
   62 |   for (size_t i = 1; i < score_column.size(); ++i) {
      |   ^
../solution.cpp:62:3: remark: the cost-model indicates that interleaving is not beneficial [-Rpass-missed=loop-vectorize]
../solution.cpp:84:7: remark: the cost-model indicates that interleaving is not beneficial [-Rpass-analysis=loop-vectorize]
   84 |       for (size_t k = 0; k < sequence_count_v; ++k) {
      |       ^
../solution.cpp:84:7: remark: vectorized loop (vectorization width: 16, interleaved count: 1) [-Rpass=loop-vectorize]
```

注：`remark: the cost-model indicates that interleaving is not beneficial` 

这个警告信息表明 Clang 的成本模型经过分析后认为，对循环进行交错（interleaving） 优化不会带来性能收益，因此决定不执行这种优化。
这个警告通常不需要担心，除非你在性能分析中确实发现这个循环是性能瓶颈。在大多数情况下，相信编译器的成本模型是正确的决策。


### 注：interleave 交错

交错是一种循环优化技术，它将循环的多次迭代"交织"在一起执行，以更好地利用指令级并行性和隐藏内存访问延迟。

简单例子：

原始循环：
```c
for (int i = 0; i < 8; i++) {
    a[i] = b[i] + c[i];
}
```

交错后的概念版本（交错因子=2）：
```c
for (int i = 0; i < 8; i += 2) {
    a[i]   = b[i]   + c[i];     // 迭代 i
    a[i+1] = b[i+1] + c[i+1];   // 迭代 i+1
}
```

为什么编译器认为交错"不有益"？

1. 寄存器压力过大
```c
// 这个循环如果交错，需要太多寄存器
for (int i = 0; i < n; i++) {
    result[i] = a[i] * b[i] + c[i] * d[i] + e[i] * f[i];
}
```
每个迭代需要：`a[i]`, `b[i]`, `c[i]`, `d[i]`, `e[i]`, `f[i]`, `result[i]`

如果交错4次，需要 7个变量 × 4次交错 = 28个向量寄存器

可能超出目标架构的物理寄存器数量

2. 指令缓存压力
```c
// 复杂循环体
for (int i = 0; i < n; i++) {
    double x = input[i];
    double y = some_complex_function(x);
    double z = another_complex_calculation(y);
    output[i] = final_transform(z);
}
```
每个迭代的代码已经很大

交错会导致循环体代码膨胀，可能不适合指令缓存

3. 数据依赖限制
```c
// 存在轻度的数据依赖
for (int i = 0; i < n; i++) {
    sum += data[i];  // 存在累加依赖
    results[i] = data[i] * factor;
}
```
虽然主要的数组访问可以向量化，但sum的依赖限制了交错的好处

4. 内存访问模式不佳
```c
// 内存访问模式复杂
for (int i = 0; i < n; i++) {
    output[i] = input1[i] * input2[i] + input3[i * stride];
}
input3[i * stride]的非连续访问降低了交错的好处
```
