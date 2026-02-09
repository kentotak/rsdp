---
title: 'RSDP: A MATLAB application for the evaluation of residual stress as a function of depth.'
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
Any processing of materials, whether thermal, mechanical or of any other nature, induces stresses that remain trapped in finished components until they are relieved by their use in service. Those residual stresses can cause early failure of materials or, on the contrary, reinforce them and increase their lifespan [@hauk_structural_1997; @withers_residual_2001; @withers_residual_2001-1].

Works in recent years have been directed towards the estimation of local residual stresses at fine scale, which was made possible by the development of a technique called Focused Ion Beam - Digital Image Correlation (FIB-DIC). This method allows to measure the amplitude of residual stress inside a volume of material milled by means of a gallium ion beam and electron beam imaging [@korsunsky_focused_2009].

Latest developments of FIB-DIC have led to the possibility of following the variation of residual stresses inside the volume milled using an eigenstrain approach [@salvati_generalised_2019;@sebastiani_nano-scale_2020]. However, code written in the context of this work was never published although it was used in another paper [@everaerts_nanoscale_2019]. 

# Statement of need
`RSDP` builds up on a previous MATLAB package developed in the context of the iStress project [@senn_digital_2025]. It adds on the original software by introducing depth profiling of residual stress as described by @salvati_generalised_2019.


Moreover, additional functions in the application were added to account for the case where the user wants to analyze multiple points.

<!-- # State of the field
As mentioned above, a Matlab application was developped in the frame of the iStress project for the DIC analysis. However, some defaults during my analysis:
- As I was processing multiple datasets, I found the repetitive clicking and prompts not suited for my use.
- I wanted to include depth profiling as an option in the software.
- The original DIC code did not account for a rotation of the markers grid.
- The original DIC app was written in GUIDE and some elements were rewritten in App designer. -->

# Software design
## Changes compared to the original DIC code
To avoid repetitive input, the prompts were changed to fields. This allows the user to analyze multiple datasets with the same set of parameters. Some other changes include:
- A clearer image processing
- An option to automatically generate a file list

## New functions
### Depth profiling
The DIC analysis outputs a strain file that is then used to calculate stress as a function of depth.
<table>
    <tr>
        <td>
            <figure>
                <img src="./images/example-strain-01.png">
                <figcaption>
                    <i>Strain as a function of depth</i>
                </figcaption>
            </figure>
        </td>
        <td>
            <figure>
                <img src="./images/example-dp-01.png">
                <figcaption>
                    <i>Residual stress depth profile</i>
                </figcaption>
            </figure>
        </td>
    </tr>
</table>


# References
