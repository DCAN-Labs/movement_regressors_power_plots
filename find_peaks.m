function [peak_at,B,I]=find_peaks(X,Y)


% X=x;
% Y=smoothdata(10*log10(y),'movmedian',5);
[B I]=max(Y);
peak_at=X(I);
