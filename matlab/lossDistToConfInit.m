function [ cint ] = lossDistToConfInit( pvals, lossDist, conf  )
%UNTITLED Summary of this function goes here
%   Conf: eg. 0.95 for 95% conf int

cumLossDist = cumtrapz(pvals,lossDist);
cumLossDist = cumLossDist / max(cumLossDist);

low_thresh = (1-conf)/2;
high_thresh = 1 - low_thresh;

[~,ind] = min(abs(cumLossDist - low_thresh));
clow = pvals(ind);

[~,ind] = min(abs(cumLossDist - 0.5));
mid = pvals(ind);

[~,ind] = min(abs(cumLossDist - high_thresh));
chigh = pvals(ind);

cint = [clow,mid,chigh];




end

