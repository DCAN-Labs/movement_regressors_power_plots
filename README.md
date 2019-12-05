# Movement Regressors power plots

Matlab code to visualize power spectra on head movement regressors as reported on the manuscript “Correction of respiratory artifacts in MRI head motion estimates”, Neuroimage.

**Repo location**: https://github.com/DCAN-Labs/movement_regressors_power_plots/

Here we release four utilities. Each one has their one documentation, example(s) and data. The utilities are:


- **cat_mov_reg_power:** This function concatenate the relative contribution of power of each frequency band from multiple subjects.
  - *Documentation*: `01_to_run_cat_mov_reg_power.pdf`

- **power_per_Resting:** This is a companion figure to cat_mov_reg_power. It shows the power spectra from each movement regressor.
  - *Documentation*: `02_to_run_power_per_Resting.pdf`

- **get_peaks_from_movement_regressors:** This function identifies the peak in the spectrum.
  - *Documentation*: `03_to_run_get_peaks_from_movement_regressors.pdf`

- **aliased_RR:** This function displays a table with the aliased frequency (in Hz) of a signal provided in events per minute (RR_bpm). You also need to provide the TR in seconds.
  - *Documentation*: `04_to_run_aliased_RR.pdf`
