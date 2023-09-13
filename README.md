# Exploring time-extended complexity measures in magnetic systems

Github repository containing code in order to compute the multiscale structural complexity (MSC), both static and extended with time correlations, for magnetic systems simulated using UppASD [1,2].

Include in this repository are:

- `complexity.jl` - Main file containing functions to compute various complexities.
- `t_corr.jl` - Example demonstrating how to use the functions from `complexity.jl`.

## MSC

At a scale $k$, the smallest entity/pixel that can be resolved is denoted by $s_{i j l}(k)$, which in terms of atomistic spin dynamics represents the magnetic unit cell. Each index of $s_{i j l}(k)$ then is one of three spin components. Rescaling a coarse-grained entity admits a straightforward way to compute its overlap with different scales.
At some arbitrary scale $k$, assume the system is represented by a matrix of size $L_{k,x}$ by $L_{k,y}$, which can be further coarse-grained into a matrix using blocks of size $\Lambda_x$ by $\Lambda_y$. The overlap at consecutive scales is then given by

```math
\mathcal{O}_{k, k-1} =\frac{1}{L_{k-1,x}\,L_{k-1,y}} \sum_{i=1}^{L_{k,x}}\sum_{j=1}^{L_{k,y}} \mathbf{s}_{i j}(k) \cdot \sum_{m=1}^{\Lambda_x} \sum_{l=1}^{\Lambda_y} \mathbf{s}_{\Lambda_x i+m, \Lambda_y j+l}(k-1)\\
```
```math
=\frac{\Lambda_x\Lambda_y}{L_{k-1,x}\,L_{k-1,y}} \sum_{i=1}^{L_{k,x}} \sum_{j=1}^{L_{k,y}} \mathbf{s}_{i j}^2(k)\\
\overset{*}{=}\frac{\Lambda_x\Lambda_y}{L_{k-1,x}\,L_{k-1,y}} \cdot L_{k,x}L_{k,y} \cdot \mathcal{O}_{k, k}=\mathcal{O}_{k, k}.
```

Using the overlap at different scales, the complexity for $N$ renormalization steps, i.e. considering $N$ different scales, can be defined as
```math
\mathcal{C}=\sum_{k=0}^{N-1}\mathcal{C}_k=\sum_{k=0}^{N-1}|\mathcal{O}_{k+1,k}-\frac{1}{2}(\mathcal{O}_{k,k}+\mathcal{O}_{k+1,k+1})|\overset{*}{=}\frac{1}{2}\sum_{k=0}^{N-1}|\mathcal{O}_{k+1;k+1}-\mathcal{O}_{k;k}|$$\overset{**}{=}\sum_{k=0}^{N-1}|\mathcal{O}_{k+1;k+1}-\mathcal{O}_{k;k}|.$$
```

Extending the complexity to include time correlations can be achieved as straightforwardly as treating time as an additional dimension to coarse-grain. By adding an extra time scale $\kappa$ and additional sizes $T_{\kappa}$ and $\Lambda_T$ used for temporal coarse-graining, the spatial overlap can be extended to a spatiotemporal overlap

```math
\mathcal{O}_{(\kappa,k);(\kappa-1,k-1)} =\frac{1}{T_{\kappa-1}\,L_{k-1,x}L_{k-1,y}} \sum_{t=1}^{T_{\kappa}}\sum_{i=1}^{L_{k,x}} \sum_{j=1}^{L_{k,y}}
\sum_{n=1}^{\Lambda_T}  \sum_{m=1}^{\Lambda_x} \sum_{l=1}^{\Lambda_y} \mathbf{s}_{i j;t}(\kappa;k) \cdot\mathbf{s}_{\Lambda i+m, \Lambda j+l;\Lambda_T t+n}(\kappa-1;k-1)
```
```math
=\frac{\Lambda_x\Lambda_y\Lambda_T}{T_{\kappa-1}\,L_{k-1,x}L_{k-1,y}} \sum_{t=1}^{T_{\kappa}} \sum_{i=1}^{L_{k,x}} \sum_{j=1}^{L_{k,y}} \mathbf{s}_{i j;t}^2(\kappa;k)
\overset{*}{=}\frac{\Lambda_x\Lambda_y\Lambda_T}{T_{\kappa-1}\,L_{k-1,x}L_{k-1,y}} \cdot L_{k,x}L_{k,y}\,{T_{\kappa}}\cdot \mathcal{O}_{(\kappa,k);(\kappa,k)}
=\mathcal{O}_{(\kappa,k);(\kappa,k)}.
```

The extension of time correlations to the complexity is a bit more intricate and relies on expanding $\mathcal{C}_k$ in a way that is consistent with going back to the finest scale in time, $\kappa\rightarrow 0$, however, expanding the static complexity in the correct way, the spatiotemporal complexity is given by

```math
\mathcal{C}=\sum_{\kappa=0}^{N_T-1}\sum_{k=0}^{N-1}\mathcal{C}_{\kappa,k}=\sum_{\kappa=0}^{N_T-1}\sum_{k=0}^{N-1}|  \mathcal{O}_{(\kappa+1,k+1);(\kappa+1,k+1)}-\mathcal{O}_{(\kappa,k+1);(\kappa,k+1)}+\mathcal{O}_{(\kappa,k);(\kappa,k)}-\mathcal{O}_{(\kappa+1,k);(\kappa+1,k)}|
```

This constitutes the main result of my work, which extends the static complexities that were proposed in [1]. These equations are implemented in the code in this repository, using UppASD to generate the data, and are hence based on the formatting of its output files.

## Results

Using the spatiotemporal complexity, one can show how correlated magnetic systems are over a range of temperatures. For this example, I have included bcc Fe, as well as an Edwards-Anderson spin glass. Spin glasses appear complex to the eye, as their spins look randomly distributed, however, for low temperatures, spin glasses still exhibit some kind of order. Include in the figure are the time-averaged complexity $\bar{\mathcal{C}}$ and the time-extended complexity ${\tilde{\mathcal{C}}}$, which contains temporal correlations between spins.

![tcorr1](https://github.com/jannesvpoppelen/Complexity/assets/98324298/390ef57e-8931-4245-a630-8cbfddb245a1)

## To do list

- Clean up code
- Properly comment code
- Parallelization of expensive routines

## References

[1] A. A. Bagrov, I. A. Iakovlev, A. A. Iliasov, M. I. Katsnelson, and V. V. Mazurenko, Proceedings of the National Academy of Sciences 117, 30241 (2020).

[2] O. Eriksson, A. Bergman, L. Bergqvist, and J. Hellsvik, Atomistic spin dynamics: foundations and applications (Oxford university press, 2017)
