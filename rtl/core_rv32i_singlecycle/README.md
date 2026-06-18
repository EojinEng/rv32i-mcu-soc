# RV32I Single-Cycle Core

## Overview

RV32I ISA를 지원하는 Single-Cycle Processor를 SystemVerilog로 구현하였다.

현재 구현된 명령어에 대해 시뮬레이션을 수행하며 기능을 검증하고 있다.

---

# Simulation

## R-Type Instruction Test

### Test Objective

R-Type 명령어의 ALU 제어 신호와 연산 결과가 RISC-V 명세와 일치하는지 검증한다.

---

### Test Program

```assembly
00A00093    // addi x1, x0, 10      ; x1 = 10
00300113    // addi x2, x0, 3       ; x2 = 3

002081B3    // add  x3, x1, x2
40208233    // sub  x4, x1, x2
002092B3    // sll  x5, x1, x2
0020A333    // slt  x6, x1, x2
0020B3B3    // sltu x7, x1, x2
0020C433    // xor  x8, x1, x2
0020D4B3    // srl  x9, x1, x2
4020D533    // sra  x10,x1,x2
0020E5B3    // or   x11,x1,x2
0020F633    // and  x12,x1,x2

00000013    // nop
00000013    // nop
00000013    // nop
```

---

### Expected Result

| Instruction | Operand | Expected Result |
|-------------|---------|----------------:|
| ADD  | 10 + 3 | 13 |
| SUB  | 10 - 3 | 7 |
| SLL  | 10 << 3 | 80 |
| SLT  | 10 < 3 | 0 |
| SLTU | 10 < 3 (unsigned) | 0 |
| XOR  | 10 ^ 3 | 9 |
| SRL  | 10 >> 3 | 1 |
| SRA  | 10 >>> 3 | 1 |
| OR   | 10 \| 3 | 11 |
| AND  | 10 & 3 | 2 |

---

### Simulation Result

> 아래 파형에서 명령어에 따라 `ALU_CONTROL` 신호가 정상적으로 변경되며, `ALU_RESULT`가 기대한 결과와 일치함을 확인하였다.

![R-Type Simulation](images/Rtype_test_1.png)

---

### Verification Summary

| Instruction | Result |
|-------------|:------:|
| ADD | ✅ Pass |
| SUB | ✅ Pass |
| SLL | ✅ Pass |
| SLT | ✅ Pass |
| SLTU | ✅ Pass |
| XOR | ✅ Pass |
| SRL | ✅ Pass |
| SRA | ✅ Pass |
| OR | ✅ Pass |
| AND | ✅ Pass |

---

## Next Verification

- [ ] I-Type
- [ ] Load
- [ ] Store
- [ ] Branch
- [ ] JAL
- [ ] JALR
- [ ] LUI
- [ ] AUIPC