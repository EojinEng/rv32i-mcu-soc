# RV32I MCU SoC

## 프로젝트 소개

RV32I 기반의 RISC-V 프로세서를 중심으로 다양한 주변장치(Peripheral)를 통합하여 하나의 MCU(System-on-Chip)를 구현하는 프로젝트입니다.

SystemVerilog를 사용하여 RTL을 설계하고, Xilinx Vivado 환경에서 기능 검증 및 FPGA 구현을 목표로 합니다.

본 프로젝트는 **멀티사이클(Multi-Cycle) RV32I 프로세서**를 기반으로 하며, UART, SPI, I²C, GPIO 등의 주변장치를 단계적으로 추가하여 확장 가능한 MCU 플랫폼을 구축하는 것을 목표로 합니다.

---

## 개발 목표

* RV32I Multi-Cycle Processor 설계
* 모듈화된 MCU 아키텍처 구현
* 주변장치 인터페이스 설계 및 통합
* FPGA 기반 동작 검증
* 확장 가능한 SoC 플랫폼 구축

---

## 개발 예정 구성

### Processor
* RV32I Single-Cycle Core
* RV32I Multi-Cycle Core

### Memory

* Instruction Memory
* Data Memory

### Peripheral

* GPIO
* UART
* SPI
* I²C
* Timer
* PWM
* Interrupt Controller

### System

* Memory Map
* Bus Interface
* Clock & Reset
* SoC Top Module

---

## 프로젝트 구조

```text
rv32i_mcu_soc/
├── rtl/        # RTL 설계
├── tb/         # Testbench
├── vivado/     # Vivado 프로젝트
├── docs/       # 문서 및 다이어그램
└── README.md
```

---

## 개발 환경

* **Language** : SystemVerilog
* **Tool** : Xilinx Vivado
* **ISA** : RISC-V RV32I

---

## 프로젝트 로드맵

* [ ] RV32I Multi-Cycle Core
* [ ] Instruction/Data Memory
* [ ] GPIO
* [ ] UART
* [ ] SPI
* [ ] I²C
* [ ] Timer
* [ ] Interrupt Controller
* [ ] SoC Top Integration
* [ ] FPGA Validation
