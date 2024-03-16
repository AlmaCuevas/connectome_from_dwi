clear
clc

root='/root_folder/here/';
name='ORIGINAL_DICOM_FILE.dcm';
complete=strcat(root,name);
info = dicominfo(complete)