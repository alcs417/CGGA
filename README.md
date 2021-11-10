## Cancer Subtype Identification by Consensus Guided Graph AutoEncoders(CGGA)

**:writing_hand:Update**

We have uploaded the processed cancer datasets under the cancer_datasets/ directory. Each cancer dataset consists of three omics and could be loaded into the Matlab directly.

**Method Description**

CGGA is a computational framework that can effectively and reliably uncover cancer subtypes. It mainly consists of two steps. First, for each omic, a new feature matrix is learned by using graph autoencoders, which can incorporate both structure information and node features during the learning process. Second, a set of omic-specific similarity matrices as well as a consensus matrix is learned based on the features obtained in the first step. The learned omic-specific similarity matrices are then fed back to the graph autoencoders to guide the feature learning. By iterating the two steps above, our method obtains a final consensus similarity matrix for cancer subtyping. 

**Requirements**

\>= MATLAB 2014b. 

**Usage**

To run our algorithm, please load the script 'CGGA.m' into your MATLAB programming environment and click 'run'. Users can also run the script in standard command-line mode, where you should input the following commands for each function, respectively:

matlab -nodisplay -nodesktop -nosplash -r "CGGA;exit;"

All the cancer datasets used in the code can be directly downloaded at http://acgt.cs.tau.ac.il/multi_omic_benchmark/download.html.

**Parameters**

There are three parameters in our algorithm that users can tune according to their own needs, i.e. lambda, the number of neighbors k and the number of layers in CGGA. The default values for lambda and k are fixed to 1e-5 and 15, respectively. The number of layers in CGGA is set to 2 and user can specify a larger value to construct a deeper graph autoencoder.

**Input and Output Directories**

To change the input file directory, please refer to the 'dataDir' variable in the processTCGAdata.m. For output file directory, please refer to the 'outDir' variable in the same script.

**Contact**

For any questions regarding our work, please feel free to contact us: alcs417@sdnu.edu.cn.

**Cite Our Paper**

Cheng Liang, Mingchao Shang, Jiawei Luo. Cancer subtype identification by consensus guided graph autoencoders. Bioinformatics, 2021, doi: 10.1093/bioinformatics/btab535.

