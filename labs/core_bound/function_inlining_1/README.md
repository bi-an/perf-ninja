[<img src="../../../img/FunctionInlining1Intro.png">](https://www.youtube.com/watch?v=fp1_e3rjZQs&list=PLRWO2AL1QAV6bJAU2kgB4xfodGID43Y5d&index=12)

This is a lab about [function inlining](https://en.wikipedia.org/wiki/Inline_expansion) to speed up sorting.

Function inlining is a transformation that replaces a call to a function `F` with the body for `F` specialized with the actual arguments of the call. Inlining is one of the most important compiler optimizations, not only because it eliminates the overhead of calling a function (prologue and epilogue), but also it enables other optimizations.

Whenever you find in a performance profile a function with hot prologue and epilogue, consider such function as one of the potential candidates for being inlined. In this lab assignment you will practice fixing such performance issues.

[<img src="../../../img/FunctionInlining1Summary.png">](https://www.youtube.com/watch?v=qlFUV0FjpPQ&list=PLRWO2AL1QAV6bJAU2kgB4xfodGID43Y5d&index=12)



-------

Author: @bi-an

## 控制方法

- PGO (profiling guided optimizations) 和 LTO (Link-time optimizations)
  - Profiling 指性能剖析，PGO 即以性能测试数据为导向的优化方法
    - 使用特殊的编译器标志（如 Clang/GCC 的 `-fprofile-generate`）编译你的源代码。
    - 运行上一步生成的可插桩版本程序，并使用有代表性的工作负载。
      - 插入的探测代码会将执行数据（如 `default_1234.profraw`）写入到文件中
      - 使用工具（如 llvm-profdata）将这些原始的 `.profraw` 文件合并、转换成一种编译器可以理解的格式（如 `.profdata`）
    - 引导式编译：使用正常的优化标志（如 `-O2`），并额外指定上一步生成的 profiling 数据文件（如 Clang/GCC 的 `-fprofile-use=path/to/profdata`）重新编译你的源代码
- 使用 `-fno-inline` 关闭 inline
- 使用 `-mllvm -inline-threshold=100000` 调整 cost model （成本模型）
- 使用 `[[gnu::always_inline]]` 函数属性强制关闭 inlining （MVSC使用 `__forceinline`）

