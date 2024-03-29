APPROX-MIC Implementation Details
=================================

The core implementation of libmine is built from scratch in ANSI C starting from
the pseudocode provided in DOI: 10.1126/science.1205438, Supplementary On-line
Material (SOM), as no original Java source code is available. The level of
detail of the pseudocode leaves a few ambiguities and in this section we list
and comment the most crucial choices we adopted for the algorithm steps whenever
no explicit description was provided. Obviously, our choices are not necessarily
the same as in the original Java version (MINE.jar,
http://www.exploredata.net/). The occurring differences can be ground for small
numerical discrepancies as well as for difference in performance
(DOI: 10.1093/bioinformatics/bts707).

#. In SOM, Algorithm 5, the characteristic matrix :math:`M` is computed in the
   loop starting at line 7 for :math:`xy\leq B`. This is in contrast with the
   definition of the MINE measures (see SOM, Sec. 2) where the corresponding
   bound is :math:`xy<B` for all the four statistics. We adopted the same bound
   as in the pseudocode, *i.e.* :math:`xy\leq B`.

#. The MINE statistic MCN is defined as follows in SOM, Sec. 2:

    .. math::
       \textrm{MCN}(D,\epsilon) = \min_{xy<B} \{\log(xy)\colon M(D)_{x,y}
       \geq (1-\epsilon)\textrm{MIC}(D)\}

   As for MINE.jar (inferred from Table S1), we set :math:`\epsilon=0` and
   :math:`\log` to be in base 2. Finally, as specified in Point 1 above, we use
   the bound :math:`xy\leq B` as in the SOM pseudocode rather than the
   :math:`xy<B` as in the definition. This led to implement the formula:

    .. math::

       \textrm{MCN}(D,0) = \min_{xy\leq B} \{\log_2(xy)\colon M(D)_{x,y}
       = \textrm{MIC}(D)\},

   being :math:`\textrm{MIC}(D)` the maximum value of the matrix :math:`M(D)`.

#. In EquipartitionYAxis() (SOM, Algorithm 3, lines 4 and 10), two ratios are
   assigned to the variable desiredRowSize, namely :math:`\frac{n}{y}` and
   :math:`\frac{(n-i+1)}{(y-\textrm{currRow}+1)}`. We choose to consider the
   ratios as real numbers; a possible alternative is to cast desiredRowSize to
   an integer. The two alternatives can give rise to different :math:`Q` maps,
   and thus to slightly different numerical values of the MINE statistics.

#. In some cases, the function EquipartitionYAxis() can return a map :math:`Q`
   whose number of clumps :math:`\hat{y}` is smaller than :math:`y`, *e.g.* when
   in :math:`D` there are enough points whose second coordinates coincide. This
   can lead to underestimate the normalized mutual information matrix
   :math:`M_{x,y}` (SOM, Algorithm 5, line 9), where :math:`M_{x,y}` is obtained
   by dividing the mutual information :math:`I_{x,y}` for
   :math:`\min\{\log x,\log y\}`. To prevent this issue, we normalize instead
   by the factor :math:`\min\{\log x,\log \hat{y}\}`.

#. The function GetClumpsPartition(:math:`D,Q`) is discussed (SOM page 12), but
   its pseudocode is not explicitely available. Our implementation is defined
   here in :ref:`getclumpspartition`. The function returns the map :math:`P`
   defining the clumps for the set :math:`D`, with the constraint of keeping in
   the same clump points with the same :math:`x`-value.

   .. _getclumpspartition:

   .. figure:: images/alg1.png
      :align: center

      GetClumpsPartition() algorithm

#. We also explicitly provide the pseudocode for the GetSuperclumpsPartition()
   function (SOM page 13) in :ref:`getsuperclumpspartition`. This function limits
   the number of clumps when their number `k` is larger than a given bound
   :math:`\hat{k}`.  The function calls the GetClumpsPartition() and, for
   math:`k>\hat{k}` it builds an auxiliary set :math:`D_{\tilde{P}}` as an input
   for the EquipartitionYAxis function discussed above (Points 3-4).

   .. _getsuperclumpspartition:

   .. figure:: images/alg2.png
      :align: center

      GetSuperclumpsPartition() algorithm

#. We observed that the GetSuperclumpsPartition() implemented in MINE.jar may fail
   to respect the :math:`\hat{k}` constraints on the maximum number of clumps and a
   map :math:`P` with :math:`\hat{k}+1` superclumps is actually returned. As an
   example, the MINE.jar applied in debug mode (d=4 option) with the same
   parameters (:math:`\alpha=0.551`, :math:`c=10`) used in the original work to the
   pair of variables (OTU4435,OTU4496) of the Microbioma dataset, returns
   :math:`cx+1` clumps, instead of stopping at the bound :math:`\hat{k}=cx` for
   :math:`x=12,7,6,5,4\ldots`.

#. The possibly different implementations of the GetSuperclumpsPartition() function
   described in Points 6-7 can lead to minor numerical differences in the MIC
   statistics. To confirm this effect, we verified that by reducing the number of
   calls to the GetSuperclumpsPartition() algorithm, we can also decrease the
   difference between MIC computed by minepy and by MINE.jar, and they
   asymptotically converge to the same value.

#. In our implementation, we use double-precision floating-point numbers
   (``double`` in C) in the computation of entropy and mutual information values.
   The internal implementation of the same quantities in MINE.jar is unknown.

#. In order to speed up the computation of the MINE statistics, we introduced two
   improvements (with respect to the pseudo-code), in OptimizeXAxis(), defined in
   Algorithm 2 in SOM):

      * Given a :math:`(P,Q)` grid, we precalculate the matrix of
        number of samples in each cell of the grid, to speed up the
        computation of entropy values :math:`H(Q)`, :math:`H(\langle
        c_0,c_s,c_t\rangle)`, :math:`H(\langle c_0,c_s,c_t \rangle,
        Q)` and :math:`H(\langle c_s,c_t \rangle, Q)`.

      * We precalculate the entropy matrix :math:`H(\langle c_s,c_t
        \rangle, Q), \forall s, t` to speed up the computation of
        :math:`F(s,t,l)` (see Algorithm 2, lines 10--17 in SOM).

   These improvements do not affect the final results of mutual information
   matrix and of MINE statistics.
