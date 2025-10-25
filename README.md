# FIFO Design and Verification (SystemVerilog + Assertions + Coverage)

This project implements and verifies a **First-In First-Out (FIFO)** memory design using **SystemVerilog**.  
It follows an industry-style verification flow including **interface-based design**, **assertions (SVA)**, **functional coverage**, and a **self-checking scoreboard**.

---

##  Project Overview

A **FIFO** is a queue memory structure that stores and retrieves data in the same order it was written (First-In, First-Out).  
This project verifies the functional correctness of a parameterized FIFO design through:

- Randomized stimulus generation  
- Assertion-based verification (SVA)  
- Functional coverage collection  
- Golden model comparison via a scoreboard  

---

##  Design Summary

| Parameter | Description | Default |
|------------|--------------|----------|
| `FIFO_WIDTH` | Width of each data word | `16` |
| `FIFO_DEPTH` | Number of storage locations | `8` |

### **Design Features**
- Synchronous read/write operations  
- Full, Empty, Almost Full, and Almost Empty flags  
- Overflow and Underflow detection  
- Write acknowledge generation  
- Wraparound of read/write pointers  

---


##  Verification Components

| Component | Description |
|------------|-------------|
| **DUT (FIFO.sv)** | The FIFO RTL with built-in SystemVerilog Assertions (`ifdef SIM`). |
| **Interface (FIFO_if.sv)** | Connects signals between DUT, testbench, and monitor. |
| **Transaction Class** | Defines randomized input stimulus and constraints. |
| **Testbench (FIFO_tb.sv)** | Generates stimulus and triggers sampling events. |
| **Monitor (FIFO_monitor.sv)** | Captures DUT activity and forwards to coverage + scoreboard. |
| **Scoreboard (FIFO_scoreboard.sv)** | Implements a golden model for result checking. |
| **Coverage (FIFO_coverage.sv)** | Collects functional coverage from FIFO signals. |
| **Shared Package (shared_pkg.sv)** | Tracks simulation statistics (correct/error counts). |

---

## Assertion-Based Verification (ABV)

Assertions ensure protocol correctness inside the DUT.

| Assertion | Purpose |
|------------|----------|
| `wr_ack` | Checks that write acknowledge is asserted on valid writes. |
| `overflow` | Detects writes when FIFO is full. |
| `underflow` | Detects reads when FIFO is empty. |
| `full`, `empty` | Validate status flag correctness. |
| `W_wrapping`, `R_wrapping` | Ensure pointer wrap-around logic works. |
| `threshold` | Validates FIFO boundaries are respected. |

Each property is also covered for **assertion coverage** using `cover property`.

---

##  Functional Coverage

Functional coverage captures stimulus quality through covergroups:
- Write and Read enable activity
- Flag transitions (Full, Empty, Almost Full/Empty)
- Cross-coverage between enables and flags
- Overflow and Underflow event tracking

---

##  Simulation Flow (ModelSim / QuestaSim)

### **Using `run_fifo.do`**

```tcl
vlib work
vlog shared_pkg.sv FIFO_transaction.sv FIFO_coverage.sv FIFO_scoreboard.sv FIFO_monitor.sv FIFO_tb.sv FIFO_if.sv FIFO_top.sv FIFO.sv +define+SIM +cover +covercells
vsim -voptargs=+acc work.FIFO_top -cover -sv_seed 587472825
run 0
add wave *
coverage save top.ucdb -onexit -du FIFO
run -all
vcover report top.ucdb -details -annotate -all -output coverage_rpt.txt
coverage report -detail -cvg -directive -comments -output {fcover_report.txt} {}


