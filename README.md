FSS - Full System Simulation
============================

## Context
Modern electronic devices are often heterogeneous in nature. This is due to the limitations imposed by the current technology that prevent us from pushing the clock rates beyond a certain limit, and thus motivates us to step back from general purpose processors and specialize the architecture to best fit the problem at hand.

In particular, it is not uncommon to see boards that couple an [ARM](https://en.wikipedia.org/wiki/ARM_architecture) processor with an [FPGA](https://en.wikipedia.org/wiki/Field-programmable_gate_array). The former usually deals with standard operations, such as running an operating system and interfacing with the user, while the latter takes charge of the application-dependent tasks that can, in this way, take advantage of the huge parallelism it can offer. A notable example of such boards is represented by the recent [Zynq SoC](https://en.wikipedia.org/wiki/Xilinx#Zynq), but the acquisition of [Altera](https://en.wikipedia.org/wiki/Altera) by Intel supports the hypothesis that these architectures are going to become the new standard in the near future.

While the above mentioned strategy allows for impressive performance gains, the complexity of the overall system increases greatly: not only programming the two parts requires different skills (and thus the development is usually performed by two separate teams), but also the interactions between them are not easily defined, tested, and debugged. This fact makes the boundary between them one of the most critical points in the system design.

Despite well-defined best practices, the lack of appropriate tools makes it the norm to test the CPU software design using a set of test cases that are supposed to mimic the expected behavior of the FPGA, and at the same time test the FPGA on a test bench that should simulate all the possible interactions with the CPU part. As an extreme example of this practice, ARM was used to employ a VHDL simulation of Linux boot process to validate the design of new processors. These techniques are far from being the optimal solution, and involve a significant amount of duplicated work.

We claim that, in the context of heterogeneous systems composed by a CPU and an FPGA, huge benefits arise from a complete co-simulation of the two parts. Indeed, such a simulation allows full visibility on the internals of the two systems during their interaction, making it possible to spot incongruences, mistakes in the interface design, and business logic errors. Moreover, it allows to test both components while performing real interactions and operating on realistic data, instead of relying on made-up test benches.

An attempt in this direction is represented by the [RABBITS project](http://tima.imag.fr/sls/research-projects/rabbits). This framework proposes a system-level simulation based on [QEmu](https://en.wikipedia.org/wiki/QEMU) and [SystemC](https://en.wikipedia.org/wiki/SystemC). However, while the approach and the preliminary results are extremely interesting, the choice of SystemC as working language has a major impact upon the applicability of the methodologies. Indeed, while SystemC is still a promising technology, it is not yet supported by standard workflows adopted in industry.

Another related project is [SimXMD](www.eecg.toronto.edu/~willenbe/simxmd), which focuses on using [GDB](https://en.wikipedia.org/wiki/GNU_Debugger) to drive the simulation of a processor. This is similar to what we would like to achieve, but we would like to generalize the adopted approach by letting GDB (or QEmu, in our case) take control of the simulation and interact with it.

## The FSS Approach
