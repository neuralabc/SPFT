function [amplitude_ratio, ind2]=SPFT_calcTemporalOffset(ref,resp)
% Chris Steele (built from some matlab help postings)
% Aug 20,2013
% Function to calculate the temporal offset of a sequence and response (of
% equal lenght)
%
%
% input: ref(erence) sequence, resp(onse) of subject
% output:
%        amplitude_ratio-   magnitude difference of amplitude
%                           (multiplicative factor) i.e., 1.5 means that
%                           the resp is 1/1.5 times smaller than ref
%        ind2           -   time shift, in units of the input vectors, of lag
%                           for resp relative to ref (i.e., lag of -20 means 
%                           the resp started 20 units after the ref; 20
%                           means 20 units early). This can be converted to
%                           time with knowledge of the sample rate.
% 
% ind will indicate the time shift and normratio the difference in magnitude. 
% Both can be used as features for your similarity metric. 
% I assume however your signals actually vary by more than just timeshift or magnitude in which case some sort of signal parametrisation may be a better choice and then building a metric on those parameters.
        
%calculate the cross correlation between the two curves and find the lag
%where it is maximal
[xc lags]=xcorr(ref,resp);
[m i]=max(xc);
ind2=lags(i); %reports the lag, not the ms associated with it (though lag of 1 = seqLength/time(ms))

%another possible way to do it
refn=ref/norm(ref);
respn=resp/norm(resp);
amplitude_ratio=norm(ref)/norm(resp);
c=conv2(refn,respn,'same');
[val ind]=max(c);
%ind2