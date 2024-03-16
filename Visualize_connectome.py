#!/usr/bin/env python3
#
# ===============================================================================
# Metadata
# ===============================================================================
__author__ = 'AC'
__contact__ = 'XXXX'
__copyright__ = ''
__license__ = ''
__date__ = '01/2022'
__version__ = '0.1'

# ===============================================================================
# Import statements
# ===============================================================================
import sys
import mne
import pandas as pd
import numpy as np
import scipy as sp
from scipy import io
import numpy as np
import matplotlib.pyplot as plt
import os
# The actual function
def Visualize_con(W_cmatrix, ID_nm, root_path, show_bool):
    # Reading files
    if isinstance(W_cmatrix, np.ndarray):
        W_orig=W_cmatrix
    elif W_cmatrix[-3:] == 'mat':
        W_orig=sp.io.loadmat(W_cmatrix)
        keys = list(W_orig.keys())
        keys.remove('__version__')
        keys.remove('__globals__')
        keys.remove('__header__')
        W_orig = W_orig[keys[0]]
    elif W_cmatrix[-3:] == 'csv': 
        W_orig = pd.read_csv(W_cmatrix, header=None).to_numpy()
    else:
        print("try again, only mat, csv or numpy array")
    # % https://community.mrtrix.org/t/visualising-processing-tck2connectome-output/1941/6 to see the example code
    
    label_names= ['Bankssts-lh', 'Caudal Anterior Cingulate-lh', 'Caudal Middle Frontal-lh',
		              'Cuneus-lh', 'Entorhinal-lh', 'Fusiform-lh',
		              'Inferior Parietal-lh', 'Inferior Temporal-lh', 'Isthmus Cingulate-lh',
		              'Lateral Occipital', 'Lateral Orbito Frontal-lh', 'Lingual-lh',
		              'Medial Orbito Frontal-lh', 'Middle Temporal-lh', 'Parahippocampal-lh',
		              'Paracentral-lh', 'Parsopercularis-lh', 'Parsorbitalis-lh',
		              'Parstriangularis-lh', 'Pericalcarine-lh', 'Postcentral-lh',
		              'Posterior Cingulate-lh', 'Precentral-lh', 'Precuneus-lh',
		              'Rostral Anterior Cingulate-lh', 'Rostral Middle Frontal-lh', 'Superior Frontal-lh',
		              'Superior Parietal-lh', 'Superior Temporal-lh', 'Supramarginal-lh',
		              'Frontal Pole-lh', 'Temporal Pole-lh', 'Transverse Temporal-lh',
		              'Insula lh', 'Cerebellum Cortex-lh', 'Thalamus Proper-lh',
		              'Caudate-lh', 'Putamen-lh', 'Pallidum-lh',
		              'Hippocampus-lh', 'Amygdala-lh', 'Accumbens Area-lh',
		              
		              
		              'rh-Thalamus Proper', 'rh-Caudate', 'rh-Putamen',
		              'rh-Pallidum', 'rh-Hippocampus', 'rh-Amygdala',
		              'rh-Accumbens Area', 'rh-Bankssts', 'rh-Caudal Anterior Cingulate',
		              'rh-Caudal Middle Frontal', 'rh-Cuneus', 'rh-Entorhinal',
		              'rh-Fusiform', 'rh-Inferior Parietal', 'rh-Inferior Temporal',
		              'rh-Isthmus Cingulate', 'rh-Lateral Occipital', 'rh-Lateral Orbito Frontal',
		              'rh-Lingual', 'rh-Medial Orbito Frontal', 'rh-Middle Temporal',
		              'rh-Parahippocampal', 'rh-Paracentral', 'rh-Parsopercularis',
		              'rh-Parsorbitalis', 'rh-Parstriangularis', 'rh-Pericalcarine',
		              'rh-Postcentral', 'rh-Posterior Cingulate', 'rh-Precentral',
		              'rh-Precuneus', 'rh-Rostral Anterior Cingulate', 'rh-Rostral Middle Frontal',
		              'rh-Superior Frontal', 'rh-Superior Parietal', 'rh-Superior Temporal',
		              'rh-Supramarginal', 'rh-Frontal Pole', 'rh-Temporal Pole',
		              'rh-Transverse Temporal', 'rh-Insula', 'rh-Cerebellum Cortex']
    order_names= ['Bankssts-lh', 'Caudal Anterior Cingulate-lh', 'Caudal Middle Frontal-lh',
		              'Cuneus-lh', 'Entorhinal-lh', 'Fusiform-lh',
		              'Inferior Parietal-lh', 'Inferior Temporal-lh', 'Isthmus Cingulate-lh',
		              'Lateral Occipital', 'Lateral Orbito Frontal-lh', 'Lingual-lh',
		              'Medial Orbito Frontal-lh', 'Middle Temporal-lh', 'Parahippocampal-lh',
		              'Paracentral-lh', 'Parsopercularis-lh', 'Parsorbitalis-lh',
		              'Parstriangularis-lh', 'Pericalcarine-lh', 'Postcentral-lh',
		              'Posterior Cingulate-lh', 'Precentral-lh', 'Precuneus-lh',
		              'Rostral Anterior Cingulate-lh', 'Rostral Middle Frontal-lh', 'Superior Frontal-lh',
		              'Superior Parietal-lh', 'Superior Temporal-lh', 'Supramarginal-lh',
		              'Frontal Pole-lh', 'Temporal Pole-lh', 'Transverse Temporal-lh',
		              'Insula lh', 'Cerebellum Cortex-lh', 'Thalamus Proper-lh',
		              'Caudate-lh', 'Putamen-lh', 'Pallidum-lh',
		              'Hippocampus-lh', 'Amygdala-lh', 'Accumbens Area-lh',
		              
		              
		              'rh-Accumbens Area', 'rh-Amygdala', 'rh-Hippocampus', 
		              'rh-Pallidum', 'rh-Putamen', 'rh-Caudate', 'rh-Thalamus Proper', 
		              'rh-Cerebellum Cortex', 'rh-Insula', 'rh-Transverse Temporal', 
		              'rh-Temporal Pole', 'rh-Frontal Pole', 'rh-Supramarginal', 
		              'rh-Superior Temporal', 'rh-Superior Parietal', 'rh-Superior Frontal', 
		              'rh-Rostral Middle Frontal', 'rh-Rostral Anterior Cingulate', 
		              'rh-Precuneus', 'rh-Precentral', 'rh-Posterior Cingulate', 
		              'rh-Postcentral', 'rh-Pericalcarine', 'rh-Parstriangularis', 
		              'rh-Parsorbitalis', 'rh-Parsopercularis', 'rh-Paracentral', 
		              'rh-Parahippocampal', 'rh-Middle Temporal', 'rh-Medial Orbito Frontal', 
		              'rh-Lingual', 'rh-Lateral Orbito Frontal', 'rh-Lateral Occipital', 
		              'rh-Isthmus Cingulate', 'rh-Inferior Temporal', 'rh-Inferior Parietal', 
		              'rh-Fusiform', 'rh-Entorhinal', 'rh-Cuneus', 'rh-Caudal Middle Frontal', 
		              'rh-Caudal Anterior Cingulate', 'rh-Bankssts']
    
    node_angles = mne.viz.circular_layout(label_names, order_names, start_pos=90,
		                          group_boundaries=[0, len(label_names) / 2])
    fig,_ = mne.viz.plot_connectivity_circle(W_orig, label_names, node_angles = node_angles, show=show_bool)
    
    outname='circle_' + ID_nm + '.eps'
    plot_conmat_file = os.path.join(root_path, outname)
    fig.savefig(plot_conmat_file, facecolor='black')
    
    plt.close(fig)
    del fig





# =============================================================================================
def usage():

    temp = '''
    View (optional) and save the connectome in the circle layout.

        Example call:
            Visualize_connectome.py <%s input file> <%s prefix name> <%s output root folder path> <%s Show fig>


    <%s numpy array/.csv/.mat file>   = File that contains connectome
    <%s prefix of output>  = Output file prefix name. Will output "prefix_bct_type.eps" file.
    <%s output root folder path> = Output saving folder path
    <%s Show fig> = Bool variable (True: Show and save, False: Only save) to view the connectome

    Owner: AC
    '''
    print(temp)
    exit()

# =============================================================================================
def main(argv):

    if (len(sys.argv) != 5):
        usage()

    input_connectome_file = sys.argv[1]
    outstr = sys.argv[2]
    root_path = sys.argv[3]
    show_bool = sys.argv[4]
    
    Visualize_con(input_connectome_file, outstr, root_path,show_bool)


if __name__ == "__main__":
    main(sys.argv)
