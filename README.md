[![DOI](https://zenodo.org/badge/725762092.svg)](https://doi.org/10.5281/zenodo.18807508)
# JetSchemeAlgorithms
Here you can find some code I have written for working with Jet Schemes in SageMath.

- I have implemented the algorithms that we developed, in collaboration with Julien Sebag, in our article [*Two algorithms for computing the general component of jet scheme and applications*](https://doi.org/10.1016/j.jsc.2022.02.004).
    - The file `Implementation of two algorithms for computing the general component of jet scheme in SageMath.ipynb` is a Jupyter Notebook that contains the functions along with description.
    - The file `Examples of computation of the general component of the jet scheme in SageMath.ipynb` is a Jupyter Notebook that contains the tests we have performed in the article.
    - The file `algorithms_general_component.sage` contains the needed funtions in a format that can be easily imported.
- I have implemented a few additional functions that are useful for creating and handling jet schemes global sections rings, including the ones in the previous files. Their description is not as detailed, and some of them may require further debugging. Do not hesitate to let me know if you find any issues!
    - The file `Algorithms jet scheme.ipynb` is a Jupyter Notebook that contains the functions along with description.
    - The file `algorithms_jet_scheme.sage` contains the needed funtions in a format that can be easily imported.
- These two last files also include the closed-form expressions of Gröbner bases of the ideal $\mathscr{N}_m(C)$ of nilpotent functions of the arc scheme of a curve $C$ (in a specific class or curves) that "live" in the 1-jet scheme. These expressions have been obtained in the articles [*On the tangent space of a weighted homogeneous plane curve singularity*](https://doi.org/10.4134/JKMS.j180796) and [*General jet components of homogeneous plane curve singularities*](https://doi.org/10.1007/s13348-025-00485-9), both in collaboration with Julien Sebag.
