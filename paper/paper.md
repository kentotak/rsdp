---
title: 'rsdp: A MATLAB application for the evaluation of residual stress as a function of depth.'
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
  affiliation: 3
- name: Martin Diehl
  orcid: 0000-0002-3738-7363
  affiliation: "1, 2"
- name: Joris Everaerts
  orcid: 0000-0002-8414-5877
  affiliation: 1
affiliations:
- name: Department of Materials Engineering, KU Leuven, Belgium
  index: 1
  ror: 05f950310
- name: Department of Computer Science, KU Leuven, Belgium
  index: 2
  ror: 05f950310
- name: Polytechnic Department of Engineering and Architecture, University of Udine, Italy
  index: 3
  ror: 05ht0mh31
date: 22 October 2025
bibliography: paper.bib
---

# Summary
Any processing of materials induces residual stresses that remain present in finished components, even in the absence of an externally applied load. Those residual stresses affect the mechanical properties of the material and can cause early failure or, on the contrary, reinforce them and increase their lifespan [@hauk_structural_1997; @withers_residual_2001; @withers_residual_2001-1].

Research efforts in recent years have been directed towards the evaluation of local residual stresses at the micro- to nanoscale, which was made possible by the development of the ring-core Focused Ion Beam - Digital Image Correlation (FIB-DIC) technique. This technique enables evaluation of the magnitude of average residual stress within the micropillar gauge volume via incremental milling using a FIB, imaging of the top surface of the micropillar via scanning electron microscopy, DIC analysis on those images to assess incremental strain relief as a function of milling depth and finally fitting of the data to a master curve in order to obtain the total strain relief within the gauge volume. [@korsunsky_focused_2009].

The latest developments of FIB-DIC have led to the possibility of evaluating not just the average residual stress within the gauge volume, but also the variation of residual stress as a function of depth using an eigenstrain approach [@korsunsky_nanoscale_2018; @salvati_generalised_2019], i.e., depth profiling. However, code written in the context of this work has not yet been published although it was used in other articles [@everaerts_nanoscale_2019; @sebastiani_nano-scale_2020].

`rsdp` is a tool that allows researchers to perform their entire FIB-DIC analysis process in one interface and includes those latest developments mentioned above.

# Statement of need
`rsdp` builds up on DICT, an open source  MATLAB package that was developed in the context of the iStress project [@senn_digital_2016]. DICT enables DIC analysis on a set of images (see \autoref{fig:example-DIC_grid}) and outputs a strain file (see \autoref{fig:example-strain_relief_profile}) that is then used to calculate the average residual stress of the gauge volume.

![Example of a DIC grid.\label{fig:example-DIC_grid}](./images/example-DIC_grid.png)

![Example of a strain relief profile.\label{fig:example-strain_relief_profile}](./images/strain_relief_profile-example.jpg){width=70%}

`rsdp` improves on this aspect by offering the possibility to output a residual stress depth profile (as shown in \autoref{fig:RS_profile-example}), and therefore shows depth-resolved data

The intent behind the development of `rsdp` as an application was to streamline this analysis process; this was originally done to optimize the analysis of multiple datasets.

![Example of a residual stress profile.\label{fig:RS_profile-example}](./images/RS_profile-example.jpg){width=70%}

Moreover, some changes were made to `DICT`: the package was upgraded from GUIDE to App Designer, and a few bugs were corrected.

# Software design
The philosophy behind the development of `rsdp` relies on two main points: (1) Present a clear, stepwise analysis process. (2) Limit user prompts.

The first point was achieved by having a tab structure with one step of the process allocated to each tab. The steps of the process are: (1) Data selection. (2) Image processing. (3) DIC analysis. (4) Depth profiling. (5) Additional functions.

The second point was achieved by moving all the user prompts from `DICT` to a parameters window (associated to each tab). This is especially useful for the successive analysis of multiple datasets with the same parameters (see \autoref{fig:tab-dic} and \autoref{fig:file_list_parameters}).

![DIC tab.\label{fig:tab-dic}](./images/tabs/tab-dic-02.png){width=70%}

![File list parameters \label{fig:file_list_parameters}](./images/file_list/file_list_parameters-02.png){width=50%}

Additional minor changes were made during development, such as the option to create a file list automatically, and different image processing filters among others.

# Research impact statement
As mentioned above, `rsdp` is part of recent research developments of the FIB-DIC technique. It is used in the PhD project of the main developper of the application, and has already produced tangible results that will be used in an upcoming article. Moreover, @guo_dual-variable_2025 recently extended Salvati's analysis to small scale by introducing a dual-variable influence function, that could be included in the future in `rsdp`.

# References
