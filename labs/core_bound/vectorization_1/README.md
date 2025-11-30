[<img src="../../../img/Vectorization1-Intro.png">](https://www.youtube.com/watch?v=osfIC5uO0G8&list=PLRWO2AL1QAV6bJAU2kgB4xfodGID43Y5d&index=12)

[Sequence alignment](https://en.wikipedia.org/wiki/Sequence_alignment) is an important algorithm in many bioinformatics applications and pipelines. The goal of the alignment is to gain insights about their biological  relation. In particular, one is interested how the sequences diverged from a common ancestor by evolutionary events like point mutations or insertions and deletions in the respective sequences.
This problem, however, has quadratic complexity and optimizing it can have a great benefit in many applications.
Since many bioinformatic problems start with the alignment of millions of short sequence pieces of length 150 to 300 symbols, we can gain great performance improvements by using SIMD vectors. In this lab you will learn how the algorithm can be improved by transforming the data layout and exposing SIMD computations.

[<img src="../../../img/Vectorization1-Summary.png">](https://www.youtube.com/watch?v=OvM6eAh8wBc&list=PLRWO2AL1QAV6bJAU2kgB4xfodGID43Y5d&index=12)


Author: @rrahn.


------------------------
Anthor: @bi-an

## 向量化

序列匹配算法：
对于每一对序列，进行一一比对（动态规划）：

```cpp
for (int sequence_idx = 0; sequence_idx < sequences.size(); ++sequence_idx) {
    // 动态规划
    // 先列
    for (unsigned col = 1; col <= sequence2.size(); ++col) {
        // 后行
        for (unsigned row = 1; row <= sequence1.size(); ++row) {
            ...
        }
    }
}
```

可见，对于每一对序列的所有操作都是一样的，也即可以并行化（向量化）。


## 缓存友好性（AOS --> SOA）

转置前（序列优先布局）：
```text
维度: [sequence_count_v][sequence_size_v]
数据:
[0]: A C G T A C ...  // 序列1的所有字符
[1]: G C T A G C ...  // 序列2的所有字符  
[2]: T A A C T A ...  // 序列3的所有字符
...
```

转置后（位置优先布局）：
```text
维度: [sequence_size_v][sequence_count_v]  
数据:
[0]: A G T ...  // 所有序列的第1个字符
[1]: C C A ...  // 所有序列的第2个字符
[2]: G T A ...  // 所有序列的第3个字符
[3]: T A C ...  // 所有序列的第4个字符
...
```

数据对齐和连续访问：
```cpp
// 转置后，可以一次性处理所有序列的同一个位置
for (size_t k = 0; k < sequence_count_v; ++k)
    best_cell_score[k] += (trSeq1[row - 1][k] == trSeq2[col - 1][k] ? match[k] : mismatch[k]);
```

## 拓展1：序列对齐算法

序列对齐是指将两个或多个序列进行排列比较，通过插入间隔（gaps）来突出它们之间的相似性区域。

DNA/RNA/蛋白质序列比对

```text
序列1: A T G C - T A C G
序列2: A T - C T T A C G
      | |   | | | | |
匹配:  ✓ ✓   ✓ ✓ ✓ ✓ ✓
```

评分奖罚机制：

- 匹配: 相同字符对齐（+6分）
- 错配: 不同字符对齐（-4分）
- 缺失: 一个序列有字符，另一个对应位置是gap：
  - Gap开启: -11分（开始一个新的gap）
  - Gap扩展: -1分（延长已有的gap）
    - 鼓励连续的空位而不是多个分散的空位

## 拓展2：自动向量化（Auto Vectorization）

编译器可以自动将代码中的标量操作转换为向量操作（SIMD 指令）。

### clang 编译选项

#### 优化级别
- `-O2`：在 Clang 中，-O2 默认就开启了循环向量化，这与 GCC 不同。
- `-O3`：启用更激进的优化，包括循环向量化和 SLP 向量化。
- `-Os`：优化代码大小，可能会禁用一些向量化。

#### 显式向量化选项
- `-Rpass=loop-vectorize`：报告成功向量化的循环（相当于 GCC 的 -fopt-info-vec）
- `-Rpass-missed=loop-vectorize`：报告未能向量化的循环及原因
- `-Rpass-analysis=loop-vectorize`：提供向量化决策的详细分析

#### 架构特定优化
- `-march=native`：为当前CPU生成最优代码（`march` 是 Machine Architecture 的缩写）
- `-mtune=native`：针对当前CPU微调

#### 浮点数学优化
- -ffast-math：放宽浮点约束，极大提升向量化能力
  - 消除 “特殊值检查” 的分支依赖：比如 `x[i] = sqrt(y[i]);  // 需检查 y[i] 是否为负/NaN`，`-ffast-math` 则直接跳过；
  - 允许运算重排：IEEE 754 标准要求浮点数运算遵循严格的顺序，如 `(a+b)+c` 不等于 `a+(b+c)`，因精度舍入；
  - 允许 “常量传播” ：如 `sqrt(4.0)`→`2.0`；
  - 允许 “函数内联”：如将标准数学函数（如 sin/cos/exp）替换为更快的内置向量函数（如 `__vrs4_sin`），这些函数可直接被向量指令处理。
- -fvectorize：启用向量化（默认在O2以上已开启）
- -fslp-vectorize：启用 SLP（超字级并行）向量化

```bash
# 对浮点代码最有效的组合
clang -O3 -march=native -ffast-math -Rpass=loop-vectorize example.c -o example
```

#### SLP 向量化
SLP 向量化可以将多个相似的标量操作合并为向量操作。
- -fslp-vectorize

```bash
# 启用 SLP 向量化（O3默认开启）
clang -O2 -fslp-vectorize -Rpass=slp-vectorize example.c -o example

# 查看 SLP 向量化失败原因
clang -O2 -fslp-vectorize -Rpass-missed=slp-vectorize example.c -o example
```

#### 强制向量化选项
- -fno-vectorize：禁用向量化
- -fno-slp-vectorize：禁用 SLP 向量化

```bash
# 禁用所有向量化进行对比测试
clang -O2 -fno-vectorize -fno-slp-vectorize example.c -o example_no_vec
```

#### 目标特定向量化
你可以指定使用特定的向量指令集：
```bash
# 针对特定指令集
# `avx` 是 Advanced Vector Extensions 的缩写。
clang -O3 -mavx2 -Rpass=loop-vectorize example.c -o example
clang -O3 -msse4.2 -Rpass=loop-vectorize example.c -o example

# 或者让编译器自动选择
clang -O3 -march=native -Rpass=loop-vectorize example.c -o example
```

#### OpenMP SIMD 支持
```bash
# 启用 OpenMP SIMD
clang -O3 -fopenmp-simd -Rpass=loop-vectorize example.c -o example

# 或者完整的 OpenMP 支持
clang -O3 -fopenmp -Rpass=loop-vectorize example.c -o example
```

#### 诊断信息解读
Clang 的诊断信息通常比 GCC 更易读：
```text
example.c:15:3: remark: vectorized loop (vectorization width: 4, interleaved count: 2) [-Rpass=loop-vectorize]
  for (int i = 0; i < n; i++) {
  ^
```

这表示：

- vectorization width: 4：使用 4 个元素的向量（如 128-bit SSE 打包 4 个 float）
- interleaved count: 2：循环被展开并交错处理

#### 推荐配置

对于性能关键代码：
```bash
clang -O3 -march=native -ffast-math -Rpass=loop-vectorize -Rpass-missed=loop-vectorize example.c -o example
```

对于需要严格浮点精度的代码：
```bash
clang -O3 -march=native -Rpass=loop-vectorize -Rpass-missed=loop-vectorize example.c -o example
```

用于调试和分析：
```bash
clang -O3 -march=native -ffast-math -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize example.c -o example
```


### gcc 编译选项

- `-O3`：开启所有主要优化，包括自动向量化。
- `-march=native`：针对你当前的CPU生成最优化的向量指令（如 AVX2）。
- `-ffast-math`：打破浮点数限制，极大提高浮点循环向量化的成功率。
- `-fopt-info-vec-missed`：查看哪些循环没有被向量化以及原因，便于你进一步优化代码。
