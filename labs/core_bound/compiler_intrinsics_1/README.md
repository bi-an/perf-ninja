[<img src="../../../img/CompilerIntrinsics1-Intro.png">](https://www.youtube.com/watch?v=mlXw_qYRi78&list=PLRWO2AL1QAV6bJAU2kgB4xfodGID43Y5d&index=12)

This is a lab about using [compiler intrinsics](https://en.wikipedia.org/wiki/Intrinsic_function) to speed up parts of the code, where compilers fail to generate optimal code.

The kernel in this lab assignment is a part of the Average ImageSmoothing algorithm, which is reduced to 1 dimension and lacks division part. The algorithm uses sliding window approach to compute a sum in the subrange [-radius .. +radius]. It is a very fast approach compared to a classical Gaussian blur.

[<img src="../../../img/CompilerIntrinsics1-Summary.png">](https://www.youtube.com/watch?v=fP6Rhwf3rEs&list=PLRWO2AL1QAV6bJAU2kgB4xfodGID43Y5d&index=12)

Author: @adamf88.


---------------------

Author: @bi-an

## Compiler Intrinsics（编译器内联函数）

编译器内联函数 是一种特殊的函数，它看起来和普通函数一样，但它的实现不是由开发者编写的代码提供的，而是直接由编译器在内部提供和实现的。

你可以把它理解为编译器“认识”的一些特殊名字。当编译器在代码中看到这些名字时，它不会去链接外部的库文件，而是直接生成对应的、高度优化的机器指令序列，或者对这些函数调用进行特殊的处理。

- 编译器内联函数经常被映射为单条汇编指令。
- 可以用作强制生成特定一组的汇编指令。
- 比直接写内联汇编代码更好（可读性、允许编译器类型检查）。

文档：

- [Intel Intrisics Guide](https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html)
- [Intel C++ Intrinsics Reference](https://www.intel.com/content/dam/develop/external/us/en/documents/18072-347603.pdf)
- [ARM Intrinsics](https://developer.arm.com/architectures/instruction-sets/intrinsics)

## Caveats（注意事项）

1. 程序员需要保证代码的正确性
2. 编译器内联函数不可移植（应该提供其他架构的可选版本）
3. 可读性差


## TODO

CPU 有 lane 的概念，使用 AVX2 (256 bit 向量)，并不一定能提高效率，因为 lane 是 128 bit 的。

