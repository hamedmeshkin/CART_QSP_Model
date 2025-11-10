from pypdf import PdfWriter
import os

merger = PdfWriter()
patients = ( "L1", "L2","L3","L4", "L6","L7", "P01","P02","P03", "P05",	 "P09", "P10","P12", "M03","M09","M21",  "M57","M68","G01","P22","M04",	"M19","M26","M44", "G02")
# Loop through directories output/1 to output/100
for patient in patients:
    pdf_path = f"output/fitting_results/{patient}/figs/Fitting_results.pdf"
    if os.path.exists(pdf_path):
        print(f"Adding: {pdf_path}")
        merger.append(pdf_path)
    else:
        print(f"Skipping (not found): {pdf_path}")

# Write out the merged PDF
merger.write("output/merged_fittingresults.pdf")
merger.close()
print("All PDFs merged into 'merged_fittingresults.pdf'")
