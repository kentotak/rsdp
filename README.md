# `rsdp`

## Summary
`rsdp` is a `MATLAB` application intended to obtain multiple profiles of residual stress as a function of depth using ring-core Focused Ion Beam (FIB) - Digital Image Correlation (DIC). The code is mostly built on the original DIC application developed by [Melanie Senn](https://mathworks.com/matlabcentral/fileexchange/50994-digital-image-correlation-and-tracking), as well as code developed by [Enrico Salvati](https://doi.org/10.1016/j.jmps.2019.01.007).
## Installation
### System requirements
This application was developed on Windows 10 and Windows 11.
### MATLAB requirements
This application was developed in MATLAB R2024a through R2026b.
MATLAB toolbox dependencies:
- Curve Fitting Toolbox
- Optimization Toolbox
### Image processing
Image processing prior to the DIC analysis is possible, which requires [Fiji](https://imagej.net/software/fiji/) to be installed, with [Miji](https://imagej.net/plugins/miji) in the *scripts* subfolder (see the guidebook for more details).
### Installation Instructions
You may either
1. Directly download this repository.
2. Clone it using: git clone https://github.com/kentotak/rsdp.git.
The installation file can be found at `/code/release/rsdp.mltbx`. Simply double-click the file or go to the *App* tab in `MATLAB` and click on `Install app`.

**Note:** For some reason, the application appears in the *App* tab when it is installed for the first time (in version R2026b), but disappears when `MATLAB` is closed and opened again.
## Usage
To start the application, type `rsdp` in the command window.

See the documentation for more instructions on how to use `rsdp`. Please download it first as GitHub does not support figures very well.
## Contributing
Pull requests are welcome, as long as I am working on this topic. For major changes, please open an issue first.
## License
[GNU](https://choosealicense.com/licenses/gpl-3.0/)
