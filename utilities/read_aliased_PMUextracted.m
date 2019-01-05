function [RRa_Hz, HRa_Hz,RR_Hz, HR_Hz]=read_aliased_PMUextracted(PMUextracted_file,TR)


load(PMUextracted_file)



n_bold=1;
RR_Hz=zeros(n_bold,1);
HR_Hz=zeros(n_bold,1);

for j=1:n_bold
    fRR=PMUstructmat.resprate;
    fHR=PMUstructmat.pulsrate;
    
    HR=PMUstructmat.pulse(:,2);
    RR=PMUstructmat.respiration(:,2);
    
    ix=get_peak_freq(RR,fRR);
    RR_Hz(j)=ix;
    
    
    ix=get_peak_freq(HR,fHR);
    HR_Hz(j)=ix;
    
end


fs = 1/TR;
fNy=fs/2;
RRa_Hz=abs(RR_Hz-floor((RR_Hz+fNy)/fs)*fs);
HRa_Hz=abs(HR_Hz-floor((HR_Hz+fNy)/fs)*fs);
RR_min=RR_Hz*60;
HR_min=HR_Hz*60;
RRa_min=RRa_Hz*60;
HRa_min=HRa_Hz*50;

% disp(['RR_Hz = ' num2str(RR_Hz)])
% disp(['RRa_Hz = ' num2str(RRa_Hz)])
% disp(['RR_min = ' num2str(RR_min)])
% disp(['RRa_min= ' num2str(RRa_min)])
% disp(['HR_Hz = ' num2str(HR_Hz)])
% disp(['HRa_Hz = ' num2str(HRa_Hz)])
% disp(['HR_min = ' num2str(HR_min)])
% disp(['HRa_min = ' num2str(HRa_min)])





function ix=get_peak_freq(RR,fRR)
[a,b]=pmtm(detrend(RR),30,[],fRR);
% la=log10(a);
% la(1:round((length(la)/300)))=0;
% plot(b,la)
[aa, bb]=max(a);
ix=b(bb);
