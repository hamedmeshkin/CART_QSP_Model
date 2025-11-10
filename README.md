Folder structure:
data: all the clinical data
models:
parameters: for example, the opioids model parameters needed to run the simulations
simulationfunctions: dataset-specific simulation functions (to run a single patient) and other fitting-related functions


Procedure:
Step0: Data extraction - use your own code to format clinical data and put them into extracted_data
        it will contain at least one csv file for the average patient, and one csv file for each real patient


Step1: Use RunFit.sh to run fitting.R to fit all individual patients; results are in output/fitting_results, and each patient has its own folder
        fitting.R will also plot the fitting for each patient.
        Note that you will need to visually check the fitting quality of each patient; sometimes the fitting error is low
        but the fitting misses some biologically important points, like the peak or the return to baseline, then you may
        need to add more weights to those points to make the fitting more biologically plausible (even though the overall fitting
        quality may be lower)
        If you want to re-fit and plot a specific patient, you can modify the bash script

