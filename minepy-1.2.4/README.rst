minepy - Maximal Information-based Nonparametric Exploration
============================================================

.. image:: https://travis-ci.org/minepy/minepy.png?branch=master
  :target: https://travis-ci.org/minepy/minepy

.. image:: https://readthedocs.org/projects/minepy/badge/?version=latest
  :target: http://minepy.readthedocs.io/en/latest/?badge=latest
  :alt: Documentation Status

.. image:: https://anaconda.org/bioconda/minepy/badges/version.svg
  :target: https://anaconda.org/bioconda/minepy

.. image:: https://badge.fury.io/py/minepy.svg
    :target: https://badge.fury.io/py/minepy

minepy provides a library for the Maximal Information-based
Nonparametric Exploration (**MIC** and **MINE family**). Key features:

* **APPROX-MIC** (the original algorithm, DOI: 10.1126/science.1205438) and
  **MIC_e** (DOI: arXiv:1505.02213 and DOI: arXiv:1505.02214) estimators;
* **Total Information Coefficient** (TIC, DOI: arXiv:1505.02213) and the
  **Generalized Mean Information Coefficient** (GMIC, DOI: arXiv:1308.5712);
* an **ANSI C library**
* a **C++** interface;
* an efficient **Python API** (Python 2 and 3 compatibility);
* an efficient **MATLAB/OCTAVE API**;

minepy is an open-source, GPLv3-licensed software.

The `minerva` **R interface** is available at `CRAN
<https://cran.r-project.org/web/packages/minerva/index.html>`_.


MICtools
--------
The **`mine`** command-line application is deprecated since version 1.2.2.
We suggest to use MICtools, a comprehensive and effective pipeline for TICe and MICe
analysis. TICe is used to perform efficiently a high throughput
screening of all the possible pairwise relationships assessing their
significance, while MICe is used to rank the subset of significant associations
on the bases of their strength. `Paper <https://academic.oup.com/gigascience/article/7/4/giy032/4958979>`_,
`code and documentation <https://github.com/minepy/mictools>`_. 

Docker image
^^^^^^^^^^^^

The minepy library is preinstalled in the `MICtools Docker image <https://hub.docker.com/r/minepy/mictools/>`_.

Links
-----

* `Homepage and Documentation <http://minepy.readthedocs.io>`_
* `Download <https://github.com/minepy/minepy/releases>`_
* `Github page <https://github.com/minepy/minepy>`_
* `Issues <https://github.com/minepy/minepy/issues>`_
* `Old (version 1.0.0) documentation <http://minepy.sourceforge.net/docs/1.0.0/>`_


Citing minepy
-------------

Davide Albanese, Michele Filosi, Roberto Visintainer, Samantha Riccadonna,
Giuseppe Jurman and Cesare Furlanello. minerva and minepy: a C engine for the
MINE suite and its R, Python and MATLAB wrappers.  Bioinformatics (2013)
29(3): 407-408 first published online December 14, 2012
doi:10.1093/bioinformatics/bts707.

Financial Contributions
^^^^^^^^^^^^^^^^^^^^^^^

* `Computational Biology Unit - Research and Innnovation Center at Fondazione
  Edmund Mach <http://www.fmach.it/eng>`_
* `Predictive Models for Biological and Environmental Data Analysis (MPBA)
  Research Unit at Fondazione Bruno Kessler  <http://mpba.fbk.eu>`_
