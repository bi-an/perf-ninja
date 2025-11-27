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

其中，
- `-O3` 会打开自动向量化（Auto Vectorization）。 `-O2` 是触发自动向量化的最低优化级别。
- `-march=native` 会自动识别编译机器的 CPU 指令集，生成最优向量代码，无需手动改指定 AVX/AVX2/AVX512 。
  - 其中 `march` 是 Machine Architecture 的缩写，`AVX` 是 Advanced Vector Extensions 的缩写。
- `-ffast-math` 数学优化选项，放宽浮点语义，以提高向量化程度：
  - 消除 “特殊值检查” 的分支依赖：比如 `x[i] = sqrt(y[i]);  // 需检查 y[i] 是否为负/NaN`，`-ffast-math` 则直接跳过；
  - 允许运算重排：IEEE 754 标准要求浮点数运算遵循严格的顺序，如 `(a+b)+c` 不等于 `a+(b+c)`，因精度舍入；
  - 允许 “常量传播” ：如 `sqrt(4.0)`→`2.0`；
  - 允许 “函数内联”：如将标准数学函数（如 sin/cos/exp）替换为更快的内置向量函数（如 `__vrs4_sin`），这些函数可直接被向量指令处理。
- `Rpass=loop-vectorize` 报告成功向量化的循环。
- `Rpass-missed=loop-vectorize` 报告未向量化的循环及原因。
- `Rpass-analysis=loop-vectorize` 报告向量化分析细节。
