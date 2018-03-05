# Computational-imaging-reveals-mitochondrial-morphology-as-a-biomarker-of-cancer-phenotype-and-drug-r

# Project Summary
Mitochondria, which are essential organelles in resting and replicating cells, can vary in number, mass and shape. Past research has primarily focused on short-term molecular mechanisms underlying fission/fusion. Less is known about longer-term mitochondrial behavior such as the overall makeup of cell populations’ morphological patterns and whether these patterns can be used as biomarkers of drug response in human cells. We developed an image-based analytical technique to phenotype mitochondrial morphology in different cancers, including cancer cell lines and patient-derived cancer cells. We demonstrate that (i) cancer cells of different origins, including patient-derived xenografts, express highly diverse mitochondrial phenotypes; (ii) a given phenotype is characteristic of a cell population and fairly constant over time; (iii) mitochondrial patterns correlate with cell metabolic measurements and (iv) therapeutic interventions can alter mitochondrial phenotypes in drug-sensitive cancers as measured in pre- versus post-treatment fine needle aspirates in mice. These observations shed light on the role of mitochondrial dynamics in the biology and drug response of cancer cells. On the basis of these findings, we propose that image-based mitochondrial phenotyping can provide biomarkers for assessing cancer phenotype and drug response.

# Code Explanation
In the attached code repository are attached several files and their dependencies. Briefly, these files functions are:
 
**Segmentation.m** - File takes an initial image and thresholds mitochondria. Can be adjusted to use either Huang's segmentation method (function file included) or alternatively the Minimax method adapted from Ray et. al. which is a local adaptive thresholding technique. Parameters will need to be adjusted to correspond to the imaging microscope settings. 

**Classifier.m** - File takes in a segmented image, trains a computer learning algorithm (Matlab's implementation of a Random Forest method), classifies structures within the image and outputs a color coded image with the mitochondria classified into sub-groupings (punctate, intermediate, filamentous). Options to include a "donut" like structure are also included. For training purposes, a reduced length training set is included as an excel file. Again, this training set should be regenerated for your particular microscope images. 

**Single_Cell_Analysis.m** - File produces summary statistics from segmented and classified mitochondrial images for manually derived cell border regions.

Overall, these files should function as a way to quickly get a system of analyzing mitochondria as seen below up and running in your own lab. For additional information please see the complete manuscript:
https://www.ncbi.nlm.nih.gov/pubmed/27609668
