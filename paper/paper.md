---
title: 'A MATLAB application for the estimation of residual stress as a function of depth.'
tags:
- Matlab
- materials science
- residual stress
- FIB-DIC
authors:
- name: Kento Takahashi
  orcid: 0009-0009-8975-934X
  affiliation: 1
- name: Enrico Salvati
  orcid: 0000-0002-2883-0538
  affiliation: 2
- name: Martin Diehl
  orcid: 0000-0002-3738-7363
  affiliation: "1, 3"
- name: Joris Everaerts
  orcid: 0000-0002-8414-5877
  affiliation: 1
affiliations:
- name: Department of Materials Engineering, KU Leuven, Belgium
  index: 1
  ror: 05f950310
- name: Polytechnic Department of Engineering and Architecture, University of Udine, Italy
  index: 2
  ror: 05ht0mh31
- name: Department of Computer Science, KU Leuven, Belgium
  index: 3
  ror: 05f950310
date: 22 October 2025
bibliography: paper.bib
---

# Summary
Any type of processing of materials, whether thermal, mechanical or of any other nature, induces stresses that remain trapped until the finished pieces are used in service. Those residual stresses can cause early failure of materials or, on the contrary, reinforce them and increase their lifespan [@hauk_structural_1997; @withers_residual_2001; @withers_residual_2001-1].

Works in recent years have been directed towards the estimation of local residual stresses, which was made possible by the development of a technique called Focused Ion Beam - Digital Image Correlation (FIB-DIC). This method allows to measure the amplitude of residual stress inside a volume of material milled by means of a gallium ion [@korsunsky_focused_2009].

Latest developments of FIB-DIC have led to the possibility to follow the variation of residual stress inside the volume milled using an eigenstrain approach [@salvati_generalised_2019,@sebastiani_nano-scale_2020]. However, code generated in the context of this work was never published although it was used in another paper [@everaerts_nanoscale_2019].

# Statement of need
The application presented here builds up on a previous MATLAB tool developed in the context of the iStress project [@senn_digital_2025], while integrating new code written by Enrico Salvati [@salvati_generalised_2019].

Moreover, additional functions in the application were added to account for the case where the user wants to analyze multiple points.

# References
