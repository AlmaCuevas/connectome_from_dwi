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

        nRand=200
        
        
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
        
        # Normalize connectome
        # Can you normalise the networks such that a minimum number of tracts that is greater than 1 can be accounted for?
        # is equal to
        # change the network to include and keep in mind the original tracts but in small numbers (free numbers (not 0 to 1) but still real so it must be bigger than 1)?
        #range_W= np. amax(W_orig) - np. amin(W_orig[W_orig > 0])
        #W=W_orig-np. amin(W_orig[W_orig > 0])
        #W=W/range_W;
        
        
        # The multiple existance of zeros make the bct.edge_betweenness_wei(1/W) to fail, FA has the same problem
        # W[W<0] = 0
        W= W_orig / np.max(np.abs(W_orig))
        
        # BCT outputs
        clustering=np.mean(bct.clustering_coef_wu(W)) # The weighted clustering coefficient is the average "intensity" of triangles around a node.  W : NxN np.ndarray weighted undirected connection matrix
        transitivity=bct.transitivity_wu(W) #Transitivity is the ratio of 'triangles to triplets' in the network. (A classical version of the clustering coefficient). input W : NxN np.ndarray weighted undirected connection matrix 
        degrees=bct.degrees_und(W) #Node degree is the number of links connected to the node, input CIJ : NxN np.ndarray undirected binary/weighted connection matrix
        
        
        
        # The global efficiency is the average of inverse shortest path length, and is inversely related to the characteristic path length.
        # The local efficiency is the global efficiency computed on the neighborhood of the node, and is related to the clustering coefficient.
        # input: 
        # W : NxN np.ndarray        undirected weighted connection matrix (all weights in W must be between 0 and 1)
        # local : bool        If True, computes local efficiency instead of global efficiency.        Default value = False.
        efficiency_local=bct.efficiency_wei(W, local=True)
        efficiency_global=bct.efficiency_wei(W, local=False)
        
        strength=bct.strengths_und(W) # Node strength is the sum of weights of links connected to the node. CIJ : NxN np.ndarray undirected weighted connection matrix
        
        
        # The distance matrix contains lengths of shortest paths between all
        # pairs of nodes. An entry (u,v) represents the length of shortest path
        # from node u to node v. The average shortest path length is the
        # characteristic path length of the network.
        # L : NxN np.ndarray            Directed/undirected connection-length matrix.
        D,B =bct.distance_wei(1/W) 
         # D : NxN np.ndarray        distance (shortest weighted path) matrix
         # B : NxN np.ndarray        matrix of number of edges in shortest weighted path
        
        
        
        # The characteristic path length is the average shortest path length in the network.
        # input: 
        # D : NxN np.ndarray             distance matrix
        # include_diagonal : bool        If True, include the weights on the diagonal. Default value is False.
        # include_infinite : bool        If True, include infinite distances in calculation
        # output: 
        # lambda : float                characteristic path length
        # efficiency : float            global efficiency
        # ecc : Nx1 np.ndarray          eccentricity at each vertex
        # radius : float                radius of graph
        # diameter : float              diameter of graph
        characteristic_path_length=bct.charpath(D, include_diagonal=False, include_infinite=True) # option2 for output form: cp_lambda, cp_efficiency, cp_ecc, cp_radius, cp_diameter
        # lambda : float                characteristic path length
        # efficiency : float            global efficiency
        # ecc : Nx1 np.ndarray          eccentricity at each vertex
        # radius : float                radius of graph
        # diameter : float              diameter of graph
        
        
        
        
        # Node betweenness centrality is the fraction of all shortest paths in the network that contain a given node. Nodes with high values of betweenness centrality participate in a large number of shortest paths.
        betweenness=bct.betweenness_wei(W)
        # L : NxN np.ndarray directed/undirected weighted connection matrix
        
        
        # Edge betweenness centrality is the fraction of all shortest paths in the 
        # network that contain a given edge. Edges with high values of betweenness 
        # centrality participate in a large number of shortest paths.
        # L : NxN np.ndarray directed/undirected weighted connection matrix
        # EBC, BC = bct.edge_betweenness_wei(1/W)
        # EBC : NxN np.ndarray   edge betweenness centrality matrix
        # BC : Nx1 np.ndarray   nodal betweenness centrality vector
        
        #************************************************* Creation of the null model
        
        
        # Initialization
        D_r = [0] * nRand
        B_r = [0] * nRand
        shortpath = [0] * nRand
        cp_efficiency = [0] * nRand
        cluster_mean_r = [0] * nRand
        trans_r = [0] * nRand
        
        for iC in range(nRand):
        
            # This function randomizes an directed network with positive and
            # negative weights, while preserving the degree and strength
            # distributions. This function calls randmio_dir.m
            # W : NxN np.ndarray        directed weighted connection matrix
            # bin_swaps : int           average number of swaps in each edge binary randomization. Default value is 5. 0 swaps implies no binary randomization.
            # wei_freq : float          frequency of weight sorting in weighted randomization. 0<=wei_freq<1.
                    # wei_freq == 1 implies that weights are sorted at each step.
                    # wei_freq == 0.1 implies that weights sorted each 10th step (faster,
                    #     default value)
                    # wei_freq == 0 implies no sorting of weights (not recommended)
            # seed : hashable, optional
                    # If None (default), use the np.random's global random state to generate random numbers.
                    # Otherwise, use a new np.random.RandomState instance seeded with the given value.
            W_r, R =bct.null_model_und_sign(W)
            # W0 : NxN np.ndarra          randomized weighted connection matrix
            # R : 4-tuple of floats       Correlation coefficients between strength sequences of input and output connection matrices, rpos_in, rpos_out, rneg_in, rneg_out
            
            D_r[iC], B_r[iC] = bct.distance_wei(1/W_r) # distance matrix
            shortpath[iC], cp_efficiency[iC], _, _, _ = bct.charpath(D, include_diagonal=False, include_infinite=True) # path length
            cluster_mean_r[iC]=np.mean(bct.clustering_coef_wu(W_r))
            trans_r[iC]=bct.transitivity_wu(W_r)
            
            if iC % 25 == 0: 
            	#Time
            	print("Cycle " + str(iC) + ". " + datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
        print("Cycle 200. " + datetime.now().strftime("%d/%m/%Y %H:%M:%S")) #The code goes from 0-199, but to visualize the result this note was added.
        
        net_shortpath_sr = characteristic_path_length[0]/np.mean(shortpath)
        net_eglob_sr = characteristic_path_length[1]/np.mean(cp_efficiency)
        net_cluster_mean_sr = clustering/np.mean(cluster_mean_r)
        net_trans_sr = transitivity/np.mean(trans_r)
        
        cluster_by_shortpath=net_cluster_mean_sr/net_shortpath_sr
        
        
        # One by one
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_W.mat')), {"W":W})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_clustering.mat')), {"clustering":clustering})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_transitivity.mat')), {"transitivity":transitivity})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_degrees.mat')), {"degrees":degrees})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_efficiency_local.mat')), {"efficiency_local":efficiency_local})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_efficiency_global.mat')), {"efficiency_global":efficiency_global})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_D.mat')), {"D":D})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_B.mat')), {"B":B})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_characteristic_path_length.mat')), {"characteristic_path_length":np.array(characteristic_path_length,dtype=object)})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_betweenness.mat')), {"betweenness":betweenness})
        #sp.io.savemat(os.path.join(root_path, ( ID_nm +'_EBC.mat')), {"EBC":EBC})
        #sp.io.savemat(os.path.join(root_path, ( ID_nm +'_BC.mat')), {"BC":BC})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_strength.mat')), {"strength":strength})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_cluster_by_shortpath.mat')), {"cluster_by_shortpath":cluster_by_shortpath})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_net_trans_sr.mat')), {"net_trans_sr":net_trans_sr})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_net_cluster_mean_sr.mat')), {"net_cluster_mean_sr":net_cluster_mean_sr})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_net_eglob_sr.mat')), {"net_eglob_sr":net_eglob_sr})
        sp.io.savemat(os.path.join(root_path, ( ID_nm +'_net_shortpath_sr.mat')), {"net_shortpath_sr":net_shortpath_sr})
    
        
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
