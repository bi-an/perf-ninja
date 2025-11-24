cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_FLAGS="-g" -DCMAKE_CXX_FLAGS="-g"
cmake --build build --config Debug --parallel `nproc`
cmake --build build --target validateLab
cmake --build build --target benchmarkLab