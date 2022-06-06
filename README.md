
[![multi_tool](https://github.com/mattvenn/zero_to_asic_mpw6/actions/workflows/multi_tool.yaml/badge.svg)](https://github.com/mattvenn/zero_to_asic_mpw6/actions/workflows/multi_tool.yaml)

# Zero to ASIC Group submission MPW6

This ASIC was designed by members of the [Zero to ASIC course](https://zerotoasiccourse.com).

This submission was configured and built by the [multi project tools](https://github.com/mattvenn/multi_project_tools) at commit [686724010c43f1577882a5635ae3274dae0b7504](https://github.com/mattvenn/multi_project_tools/commit/686724010c43f1577882a5635ae3274dae0b7504).

The configuration files are [projects.yaml](projects.yaml) & [local.yaml](local.yaml). See the CI for how the build works.

    # clone all repos, and include support for shared OpenRAM
    ./multi_tool.py --clone-repos --clone-shared-repos --create-openlane-config --copy-gds --copy-project --openram

    # run all the tests
    ./multi_tool.py --test-all --force-delete

    # build user project wrapper submission
    cd $CARAVEL_ROOT; make user_project_wrapper

    # create docs
    ./multi_tool.py --generate-doc --annotate-image

![multi macro](pics/multi_macro_annotated.png)

# Project Index

## Function generator

* Author: Matt Venn
* Github: https://github.com/mattvenn/wrapped_function_generator
* commit: 701095fd880ad3bb80d6cec1d214a04e5676a65d
* Description: arbitary function generator, using shared RAM as the output data

![Function generator](pics/function_generator.png)

## instrumented adder - behavioural

* Author: Matt Venn & Teo
* Github: https://github.com/mattvenn/wrapped_instrumented_adder
* commit: 7a58fce17f3c8caf14c36c9c0af873d1b9f7f72b
* Description: adds a precise timer to optimised hardware adders to measure how fast they are

![instrumented adder - behavioural](pics/empty.png)

## instrumented adder - sklansky

* Author: Matt Venn & Teo
* Github: https://github.com/mattvenn/wrapped_instrumented_adder
* commit: 8e728a3da3ea22061ebd7f26293fc69ba25b7451
* Description: adds a precise timer to optimised hardware adders to measure how fast they are

![instrumented adder - sklansky](pics/empty.png)

## instrumented adder - Brent Kung

* Author: Matt Venn & Teo
* Github: https://github.com/mattvenn/wrapped_instrumented_adder
* commit: 73957a4400efe88f3b3c4ebdc0ee9da04cdb06fa
* Description: adds a precise timer to optimised hardware adders to measure how fast they are

![instrumented adder - Brent Kung](pics/empty.png)

## instrumented adder - Ripple carry

* Author: Matt Venn & Teo
* Github: https://github.com/mattvenn/wrapped_instrumented_adder
* commit: 680e190e0513b21290ed25e8ae176ef02e1f472e
* Description: adds a precise timer to optimised hardware adders to measure how fast they are

![instrumented adder - Ripple carry](pics/empty.png)

## instrumented adder - Kogge Stone

* Author: Matt Venn & Teo
* Github: https://github.com/mattvenn/wrapped_instrumented_adder
* commit: d1ffb55a18bbdc5a0d6df0e95b55fedb116627a0
* Description: adds a precise timer to optimised hardware adders to measure how fast they are

![instrumented adder - Kogge Stone](pics/empty.png)

## Wavelet Transform

* Author: Gregory Kielian
* Github: https://github.com/opensource-fr/wrapped_wavelet_transform
* commit: 28d8e5434ac8d74fbeb144382ba30574eb9f3f20
* Description: Implementation Wavelet Transform with 3 filter banks

![Wavelet Transform](pics/gds_image.png)

## PrimitiveCalculator

* Author: Emre Hepsag
* Github: https://github.com/eemreeh/wrapped_PrimitiveCalculator
* commit: cb64da0d1b9f5a622a02ee1793c288a04bf580ce
* Description: description

![PrimitiveCalculator](pics/PrimitiveCalculator.png)

