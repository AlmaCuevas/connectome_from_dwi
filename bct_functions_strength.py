#!/usr/bin/env python3
#
# ===============================================================================
# Metadata
# ===============================================================================
__author__ = 'AC'
__contact__ = 'XXXX'
__copyright__ = ''
__license__ = ''
__date__ = '12/2021'
__version__ = '0.1'

# ===============================================================================
# Import statements
# ===============================================================================
import sys
import bct
import pandas as pd
import numpy as np
import scipy as sp
from scipy import io
import os
from datetime import datetime


# The actual function
def bct_functions(W_cmatrix, ID_nm, root_path):
    with np.errstate(divide='ignore', invalid='ignore'): # To ignore 1/0 warnings

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
        
        W= W_orig / np.max(np.abs(W_orig))
        D,B =bct.distance_wei(1/W) 
        lambda_char, _, _, _, _=bct.charpath(D, include_diagonal=False, include_infinite=True) 
        
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_lambda_char.mat')), {"lambda_char":lambda_char})
        
        # return W, clustering, transitivity, degrees, efficiency_local, efficiency_global, D, B, characteristic_path_length, betweenness, EBC, BC
# =============================================================================================
def usage():

    temp = '''
    Calculates measures values from the BCT.

        Example call:
            bct_functions.py <%s input file> <%s prefix name> <%s output root folder path>


    <%s numpy array/.csv/.mat file>   = File that contains Undirected connectome
    <%s prefix of output>  = Output file prefix name. Will output "prefix_bct_type.mat" file.
    <%s output root folder path> = Output saving folder path
    
    Owner: AC
    '''
    print(temp)
    exit()

# =============================================================================================
def main(argv):

    if (len(sys.argv) != 4):
        usage()

    input_connectome_file = sys.argv[1]
    outstr = sys.argv[2]
    root_path = sys.argv[3]

    bct_functions(input_connectome_file, outstr, root_path)
#W, clustering, transitivity, degrees, efficiency_local, efficiency_global, D, B, characteristic_path_length, betweenness, EBC, BC=

if __name__ == "__main__":
    main(sys.argv)
