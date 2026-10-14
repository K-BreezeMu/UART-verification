#!/bin/bash
#====================================================================
# UART UVM 回归脚本
#====================================================================

export PATH="/d/questa/win64:$PATH"

# ---------- 根目录 ----------
ROOT="D:/ROAD/learn/UART_verification"

# ---------- 编译单元（顺序很关键！）----------
DUT_FILE="$ROOT/dut/uart.v"
PKG_FILE="$ROOT/component/uart_pkg.sv"
TOP_FILE="$ROOT/component/tb_top.sv"

# ⭐ pkg 必须放在 tb_top 前面！
SRC="$DUT_FILE $PKG_FILE: $TOP_FILE"

# ---------- `include 搜索目录 ----------
INCDIR="+incdir+$ROOT/component +incdir+$ROOT/sequence_test"

# ---------- 编译/优化 ----------
TOP="tb_top"
OPT="tb_top_opt"
TESTS="rx_test tx_test"

echo "=== vlog command line ==="
echo "vlog -sv $INCDIR $SRC"
echo ""

echo "=== Compiling ==="
vlog -sv $INCDIR $SRC
if [ $? -ne 0 ]; then
    echo "!!! vlog failed, abort."
    exit 1
fi

echo ""
echo "=== Optimizing ==="
vopt -o $OPT $TOP +acc
if [ $? -ne 0 ]; then
    echo "!!! vopt failed, abort."
    exit 1
fi

for t in $TESTS; do
    echo ""
    echo "--- Running $t ---"
    vsim -c $OPT \
         +UVM_TESTNAME=$t \
         -do "run -all; quit -f" \
         -l $ROOT/${t}.log
    if [ $? -ne 0 ]; then
        echo "!!! $t failed, check $ROOT/${t}.log"
    fi
done

echo ""
echo "=== Done. Check logs under $ROOT ==="
