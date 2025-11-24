toplev --core S0-C0 -l2 --no-desc taskset -c 0 ./lab
toplev --core S0-C0 -l2 --no-desc --run-sample taskset -c 0 ./lab
perf stat --topdown -a taskset -c 0 ./lab
