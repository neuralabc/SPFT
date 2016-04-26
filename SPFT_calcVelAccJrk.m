function [vel, acc, smt]=SPFT_calcVelAccJrk(x,resampleFactor)
% Chris Steele
% Aug 29,2013
% Function to calculate the mean of the 1st, 2nd, and 3rd derivatives of the input data
% resampleFactor included to allow binning of data so that instantaneous
% velocity, acceleration, and jerk can be calculated on smoothly varying
% signal

vel=diff(x);
acc=diff(vel);
smt=diff(acc);

vel=diff(resample(x,1,resampleFactor));
acc=diff(vel);
smt=diff(acc);


vel=mean(abs(vel));
acc=mean(abs(acc));
smt=mean(abs(smt));