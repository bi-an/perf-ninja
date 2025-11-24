cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel `nproc`
cmake --build build --target validateLab
cmake --build build --target benchmarkLab