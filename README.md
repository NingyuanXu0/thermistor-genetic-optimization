# Thermistor Circuit Optimization with a Genetic Algorithm

Select four resistor values and two thermistor models to fit a temperature-dependent voltage curve. The MATLAB implementation evolves six integer catalogue indices with tournament selection, two-point crossover, mutation and elitism, then compares convergence across repeated runs.

## Circuit and objective

The circuit model uses a 1.1 V supply, the thermistor beta relation, and two parallel resistor–thermistor branches. The target is sampled from −40 °C to 85 °C in 5 °C steps:

```text
V(T) = 0.1026 - 0.0001125 T + 0.00001125 T²
```

`objectiveFunction.m` minimizes squared voltage residuals at alternate temperature samples. The plot displays the target and selected circuit curve over the complete temperature grid.

## Files

| File | Purpose |
| --- | --- |
| `matlab/runGA.m` | Population initialization, selection, crossover, mutation, elitism and repeated runs |
| `matlab/objectiveFunction.m` | Catalogue lookup and residual sum of squares |
| `matlab/tempCompCurve.m` | Thermistor resistance and output-voltage model |
| `matlab/voltageCurve.m` | Convert catalogue indices to a voltage curve |
| `matlab/ThOptimPlot.m` | Update the best circuit curve during optimization |
| `config/StandardComponentValues.mat` | Required numerical catalogue: `Res`, `ThVal`, `ThBeta` |

The small MAT file contains component options required by the model.

## Run

Use MATLAB R2016b or later. The selected population loop uses base MATLAB operations.

From the repository root:

```matlab
run('matlab/runGA.m')
```

The entry locates its helper functions and catalogue relative to its source. It prints per-run objectives and summary tables, and opens circuit and convergence plots.

Default settings are 80 individuals, 100 generations, mutation probability 0.15 per gene, crossover probability 0.8, tournament size 3, one elite and ten runs. Edit the parameters near the top of `runGA.m` to explore other settings. Set MATLAB's random seed before the script when a repeatable random sequence is needed.

## Source and license

The implementation is selected from the author's `GA` coursework snapshot. Publication changes make catalogue loading independent of the working directory and let residual subsampling follow the supplied temperature-grid length.

Circuit helpers, plotting code and the component catalogue derive from the MathWorks example. [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) identifies these files and links the original [MathWorks license](third_party/MathWorks-LICENSE.txt), including its condition that the software and derivatives be used with MathWorks products and service offerings. Separately authored additions retain their existing ownership and unspecified reuse terms.

Publication preparation used source review. Local optimization runs and tests were not run.
