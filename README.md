# Multi-stage miniKanren

## Abstract

We introduce multi-stage miniKanren, which augments miniKanren with staging constructs that allow us to have precise control over the staging process. We have novel constructs to account for non-determinism. We use multi-stage miniKanren to stage interpreters written as relations, in which the programs under interpretation can contain holes representing unknown values. We apply this staging framework to a relational interpreter for a subset of Racket, and demonstrate significant performance gains across multiple synthesis problems.

## Getting started with Docker (optional)

The docker image can be pulled with `git pull namin/staged-minikanren` or build here with `docker build --platform=linux/amd64 -t namin/staged-minikanren .`.

Note: on Mac, _disable_ Rosetta in the Docker Desktop settings. [See this thread.](https://racket.discourse.group/t/racket-docker-m1-rosetta/2947/6)

An interactive Racket session can be run with `docker run -it namin/staged-minikanren`. Try a sanity check with the following lines:
```
> (require "all.rkt")
> (run 1 (q) (staged (== q 'fun)))
'(fun)
```

For a larger example, see [small-interp](small-interp).

The tests and benchmarks should run with `docker run -i namin/staged-minikanren` and these additional arguments:
- `racket tests/all.rkt`
- `./benchrun.sh`

You can copy the benchmark table out of the docker container with `docker cp CONTAINER_ID:/app/staged-miniKanren/bench-results/bench_paper.tex .`, where the `CONTAINER_ID` can be obtained by inspecting `docker ps -a`.

## Dependencies

Multi-stage miniKanren is a [Racket](https://racket-lang.org/) library which relies on two existing pieces of software: [syntax-spec-v2](https://pkgs.racket-lang.org/package/syntax-spec-v2), a metalanguage for implementing DSLs in Racket; and a modified version of [faster-minikanren](https://github.com/michaelballantyne/faster-minikanren), an efficient implementation of miniKanren with constraint solving. The former dependency can be installed using Racket's builtin package manager, [raco](https://docs.racket-lang.org/raco/index.html), by running the shell command:

```sh
raco pkg install syntax-spec-v2
```

The latter dependency is bundled with this project, under `private/faster-minikanren`, as a git submodule. To install this, use the following shell commands:

```sh
git submodule init
git submodule update
```

To build the plots used in the paper, an additional dependency, [`plot`: the racket plotting library](https://docs.racket-lang.org/plot/), is required. This can be installed by running the shell command:

```sh
raco pkg install plot
```

## Tests and Examples

Tests for the project are available under the [`tests/`](./tests/) directory. A test file can be run individually by running `racket FILE_TO_TEST`. Running the file [`tests/all.rkt`](./tests/all.rkt) will run the full test suite.

### Relational Interpreters

There are a number of relational interpreters for different languages in this project. The largest interpreter is for the subset of Racket used in prior papers to demonstrate relational synthesis. The version of this interpreter without annotations is in [`unstaged-interp.scm`](./unstaged-interp.scm), and the version with staging annotations is in [`staged-interp.scm`](./staged-interp.scm). Interpreters for a smaller dialect of Racket are present in the [`small-interp`](./small-interp.scm) directory. The relational interpreter for the λ-or language from Figure 8 of the paper is defined in [`tests/interp-doc.rkt`](./tests/interp-doc.rkt).

### Case Studies

The case studies presented in section 6.1 of the paper are present in the [`tests/applications/`](./tests/applications) sub-directory. These include:
- [Parsing with Derivatives](./tests/applications/parsing-with-derivatives.rkt)
- [Theorem Checker Turned Prover](./tests/applications/proof.rkt)
- [Negation Normal Form (NNF)](./tests/applications/dl.rkt)
- [Peano](./tests/applications/peano-fib.rkt)
- [Synthesis](./tests/doc-bench.rkt)
- [Double Evaluators](./tests/applications/double-eval.rkt)
- [miniKanren-in-miniKanren](./tests/applications/metamk.rkt)
- [Grammar Parsers](./tests/applications/grammars.rkt)

### Plots

The benchmarking suite includes the ability to create line plots, demonstrating the speedup staging provides for various input sizes. These plots are generated by running [`tests/graphs.rkt`](./tests/graphs.rkt), which will produce three SVG files in the `./bench-results` sub-directory. These plots were not included in the paper due to space constraints.

## Correspondences with paper

Here, we map the various claims and examples posited in the paper to corresponding tests/benchmarks in the implementation. 

### Introduction

The introduction briefly discusses the problems the paper attempts to solve, the mechanisms for solving them, as well as the contributions of the paper. It does not make major references to the implementation itself, mainly containing pointers to further into the paper. It does include Figure 1, which presents the `synth/sketch` and `invert-execute` constructs. These are syntactic sugar for various applications of the relational interpreter. The definition of and tests using the `synth/sketch` and `invert-execute` forms are in [`./tests/synth-task-macros-synth-context.rkt`](./tests/synth-task-macros-synth-context.rkt) and [`./tests/synth-task-macros-backwards.rkt`](./tests/synth-task-macros-backwards.rkt), respectively. 

### Background

#### Relational Programming in miniKanren

This section introduces prior work on the relational programming language miniKanren. The short example present in the paper used to introduce the language miniKanren is present as a test in [`./tests/doc.rkt`](./tests/doc.rkt). This section also contains Figure 2b, an implementation of the λ-or language as a relation, demonstrating the use of forms such as quasi-quote and unquote. This implementation is also present in [`./tests/or-interp-unstaged.rkt`](./tests/or-interp-unstaged.rkt), including a short test demonstrating synthesis of terms in the language.

##### Synthesis with Relational Interpreters

This section introduces the use of relational interpreters, both for synthesis and program inversion. It includes Figure 3, which demonstrates how the examples of Figure 1 are implemented in terms of the relational interpreter. These definitions, as well as a number of variations thereof, are present in [`./tests/doc-bench.rkt`](./tests/doc-bench.rkt) and [`tests/doc.rkt`](tests/doc.rkt), respectively. The short example of synthesizing the `lambda` keyword is in [`./tests/or-interp-unstaged.rkt`](./tests/or-interp-unstaged.rkt).

#### Program Staging

This section introduces traditional functional program staging using the MetaOCaml programming language. It includes Figure 4, an implementation of the language from Figure 2 in MetaOCaml, using staging to remove the overhead of interpretation. MetaOCaml can be downloaded using the [`opam` package manager](https://opam.ocaml.org/) for OCaml projects. With `opam` installed, MetaOCaml can be installed using the following commands, a modified version of those from the [MetaOCaml Website](https://okmij.org/ftp/ML/MetaOCaml.html#install):

```
opam update
opam switch add 4.14.1+BER
opam switch set 4.14.1+BER
eval `opam config env`
```

This should provide the `metaocaml` command, which runs MetaOCaml source code. The following commands run the example:

```sh
cd ./tests
metaocaml ./or-interp.ml
```

### Introduction to Multi-stage miniKanren

This section informally introduces the syntax and semantics of multi-stage miniKanren language, mainly through use of prose and examples. The first example, which introduces the `staged` and `later` annotations, is Figure 5. A test for this figure is present in [`./tests/doc.rkt`](./tests/doc.rkt). Tests for the short `pet` relation example are available in the same file. 

Figures 6 and 7 present a number of variations of the `noto` relation, demonstrating the different mechanisms for dealing with non-determinism. The definitions and tests for each variation are in [`./tests/doc-noto.rkt`](./tests/doc-noto.rkt).

#### Staged Interpreters in Multi-stage miniKanren

This section introduces the practice of writing interpreters in multi-stage miniKanren using a staged variant of the λ-or interpreter presented in Figure 2. Figure 8 gives the definition of the staged interpreter. This is equivalent to that of the prior interpreter, but now with added annotations. The definition of this interpreter and tests for it (including the example used in the paragraph before) are in [`./tests/interp-doc.rkt`](./tests/interp-doc.rkt).

##### Handling non-determinism

This section introduces the mechanisms by which nondeterminism can arise in relational interpreters; namely by the presence of non-ground staging-time terms or the use of staging-time nondeterminism to remove staging-time control-flow. The examples in this paper which demonstrate both of these phenomena are also in [`./tests/interp-doc.rkt`](./tests/interp-doc.rkt).

##### Sharing code for abstractions

This section introduces the use of higher-order relations in multi-stage miniKanren through the `partial-apply`, `finish-apply` and `specialize-partial-apply` forms. In staged relational interpreters, higher-order relations are often used to represent first-class function objects, including those in the λ-or interpreter, as shown in Figure 9. Figure 10 demonstrates how function application in the λ-or language corresponds to partially-applied relations in the generated code. Code for both figures is present in [`./tests/interp-doc.rkt`](./tests/interp-doc.rkt).

### Semantics

This section gives a formal syntax and semantics to a subset of multi-stage miniKanren. The syntax is given as a grammar in Figure 11, and the semantics are given in Figure 13 in terms of the stream abstraction described in Figure 12.

The project defines the syntax of multi-stage miniKanren using a `syntax-spec` language in [`main.rkt`](./main.rkt). That file dispatches each of the different syntactic forms present in Figure 13 in the paper to their corresponding internal implementations. The $$g\_r$$ nonterminal corresponds to the `compile-runtime-goal` DSL syntax, the $$g\_s$$ nonterminal corresponds to the `compile-now-goal` DSL syntax, and the $$g\_l$$ nonterminal corresponds to the `compile-later-goal` DSL syntax. Each of these calls different procedures prefixed with `i:`, which refer to different parts of the internal representation.

The actual miniKanren implementation which is run once at staging-time and once at run-time is a [modified version of the existing `faster-minikanren` project](./private/faster-minikanren), which implements both the stream operations presented in the paper and the traditional miniKanren goal-constructors such as `fresh`, `conde`, `==`, as well as others (see [`private/faster-minikanren/mk.scm`](./private/faster-minikanren/mk.scm)). It also includes support for unifying against the new `apply-rep` structure type, which represents partial relation applications, but is not present in the semantics. The [`private/internals.rkt`](./private/internals.rkt) file implements the new goal-constructors added to multi-stage miniKanren, such as `fallback` and `gather` (which are part of the semantics), and partial relation application and specialization (which are not). The `capture-syntax`, `generate-syntax` and `erase` metafunctions do not have direct analogues in the implementation due to complications from other concerns, such as the implicit lifting of unifications as described in Section 3.1. Similarly, there are analogues of the examples presented in Figures 14 and 15.

### Removing Interpretive Overhead from Relational Queries with Staging

#### Interpreting Functions Relationally

This section presents how functions written in languages defined by staged relational interpreters can be used as relations without interpretive overhead. Figure 16 presents a staged adaptation of the second example of Figure 3. A hand-written version of the `appendo` relation, a version written as a function in a unstaged interpreter, as well as a version written in a staged interpreter are available in [`./tests/interpreter/basics.rkt`](./tests/interpreter/basics.rkt). Evidence for the claim that the version written in a staged interpreter is nearly as efficient as the hand-written version is given in section 6.

#### Accelerating Program Synthesis by Sketch

This section presents how program synthesis using relational interpreters can be accelerated by the use of staging. It includes Figure 17, a staged adaptation of the first example of Figure 3. Several versions of the `fib` function, including the one in Figure 17, are present in [`./tests/applications/peano-fib.rkt`](./tests/applications/peano-fib.rkt). 

#### Other Staged Interpreters

This section includes two further applications of staging to relational interpretation: a relational interpreter for miniKanren itself, as well as a relational parsing mechanism. The source of both applications, including the listed examples, are present in [`./tests/applications/metamk.rkt`](./tests/applications/metamk.rkt) and [`./tests/applications/grammars.rkt`](./tests/applications/grammars.rkt), respectively.

### Evaluation

This section presents Figure 19, a table listing a number of benchmarks, showing the time taken by staged and unstaged versions of various multi-stage miniKanren queries. All of these benchmarks can be run in sequence by running [`./tests/bench-paper.rkt`](./tests/bench-paper.rkt). Each of the benchmarks prints debug information and results to `STDOUT`. To generate the exact figure used in the paper, the `benchrun.sh` bash file runs the tests, saves the results to a file, then runs the python script `benchread.py`. This script reads that file, parses the results and outputs the tex used in the figure.

The benchmarks should run in less than an hour on common commercial hardware, but can be shortened if need be. In order to decrease the timeout limit on the larger tests, modify the `timeout-limit-seconds` variable of [`./test-check.rkt`](./test-check.rkt). 

#### Comparison to a Hand-Tuned Relational Interpreter

This section presents Figure 20, a table comparing the synthesis speeds of the staged relational interpreter and of the hand-tuned relational interpreter presented in [Byrd et. al's 2017 paper](https://doi.org/10.1145/3110252), called Barliman. The code which runs and times the Barliman interpreter is in the [`tests/barliman-comparison`](tests/barliman-comparison) sub-directory. The figure itself is written by hand; see [`tests/barliman-comparison/README.md`](tests/barliman-comparison/README.md) for more information. 
