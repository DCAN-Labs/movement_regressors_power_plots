function peaks_at = get_peaks_from_movement_regressors(path_filename_mov_reg_file,TR)


%% Pre-allocate memory

peaks_at=zeros(6,1);
%% Read movement regressors

fullfilepath_mov_reg=path_filename_mov_reg_file;

try
    MR = importMovReg_patch(fullfilepath_mov_reg);
catch
    MR = importMovReg_patch(fullfilepath_mov_reg,2,inf);
end
MR_ld=make_friston_regressors(MR);%% Using this function to only get the linear displacements
MR_ld=MR_ld(:,1:6);

% mr_ld(:,:,i)=MR_ld;
% t=0:size(MR_ld,1)-1;
% t=t*TR(i);
%% Find peak
i=1;
mr_ld(:,:,i)=MR_ld;


for j=1:6
    [y,x]=pmtm(detrend(mr_ld(:,j,i)),[],[],1/TR(i));
    
    Y=detrend(smoothdata(10*log10(y),'movmedian',5));
    
    [peak_at]=find_peaks(x,Y);
    peaks_at(j)=peak_at;
end