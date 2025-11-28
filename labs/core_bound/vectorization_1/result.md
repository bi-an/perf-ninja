## 编译选项

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


## AOS to SOA

AOS (Array of Structures)
```cpp
// AOS 方式
struct Person {
    char name[20];
    int age;
    float height;
};

Person people[1000];  // 包含1000个人的数组
```

SOA (Structure of Arrays)
```cpp
// SOA 方式
struct PeopleData {
    char names[1000][20];
    int ages[1000];
    float heights[1000];
};

PeopleData allPeople;  // 包含所有人员数据的结构
```

AOS 适合：
```cpp
// 适合面向对象的操作，访问单个对象的所有属性
for (int i = 0; i < 1000; i++) {
    processPerson(people[i]);  // 一次处理一个人的所有数据
}
```

SOA 适合：
```cpp
// 适合并行处理，SIMD优化
for (int i = 0; i < 1000; i++) {
    processAllAges(ages[i]);    // 只处理年龄数据
}
for (int i = 0; i < 1000; i++) {
    processAllHeights(heights[i]);  // 只处理身高数据
}
```

1. 缓存友好性
```cpp
// SOA：连续访问同类型数据，缓存命中率高
for (int i = 0; i < n; i++) {
    sum += ages[i];  // 只访问age数据，缓存友好
}

// AOS：跳转访问不同字段，缓存不友好
for (int i = 0; i < n; i++) {
    sum += people[i].age;  // 每次访问跳过了name和height
}
```

2. 向量化优化
```cpp
// SOA 容易进行SIMD优化
__m128 age_vec = _mm_load_ps(&ages[i]);  // 一次加载4个age

// AOS 难以向量化，需要数据重组
```

3. 内存效率
   - SOA：只加载需要的数据
   - AOS：即使只需要一个字段，也要加载整个结构体