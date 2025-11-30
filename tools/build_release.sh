cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build --config Release --parallel `nproc`
cmake --build build --target validateLab
cmake --build build --target benchmarkLab