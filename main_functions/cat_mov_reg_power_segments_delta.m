function [CLIM, ix_subject_scan,MU,SIGMA,P]=cat_mov_reg_power_segments_delta(path_filename_mov_reg_file,TR,varargin)

%% Oscar Miranda-Dominguez





%% Define default values for figure creation

% these variables can be used as input using paired arguments
fig_settings.column_size_cm=8;
fig_settings.fs_title=10;
fig_settings.fs_axis=8;
fig_settings.fs_label=9;
fig_settings.fs_legend=8;
fig_settings.fig_wide=20;
fig_settings.fig_tall=10;
fig_settings.axis_color=[1 1 1];
fig_settings.fig_color=[1 1 1];
fig_settings.palette1=[230 159 0;
    86 180 233;
    0 158 115;
    213 94 0;
    0 114 178;
    204 121 167]/255;
fig_settings.palette2=[27,158,119
    217,95,2
    117,112,179]/255;

fig_settings.saturation=[.1 96];

% color limits not created
CLIM=zeros(6,2);
CLIM_provided_flag=0;

%
ix_subject_scan_provided_flag=0;

% preffix for naming the figures
tit_preffix='';

% define defalut number of segments
segments=[1 1];
%% Read extra options, if provided

v = length(varargin);
q=1;
while q<=v
    switch lower(varargin{q})
        case 'path_settings_figure' % path to a file having the size for fonts and subplots
            path_settings_figure=varargin{q+1};
            run(path_settings_figure)
            q = q+1;
            
        case 'clim' % structure that contains the colorlimits used for visualization
            CLIM=varargin{q+1};
            CLIM_provided_flag=1;
            q = q+1;
            
        case 'ix_subject_scan' % vector containing the prefered order to sort scans
            ix_subject_scan=varargin{q+1};
            ix_subject_scan_provided_flag=1;
            q = q+1;
            
        case 'mu'
            MU=varargin{q+1};
            q = q+1;
            
        case 'sigma'
            SIGMA=varargin{q+1};
            q = q+1;
            
        case 'p'
            P=varargin{q+1};
            q = q+1;
            
        case 'tit_preffix'
            tit_preffix=varargin{q+1};
            q = q+1;
            
        case 'segments'
            segments=varargin{q+1};
            q = q+1;
            
        otherwise
            disp(['Unknown option ',varargin{q}])
    end
    q = q+1;
end
%% internal variables
f=filesep;

n=length(path_filename_mov_reg_file);
frames=zeros(n,1);

mov_cell=cell(n,1);% casted as cell instead of zeros(runs*n,frames+1,6); to handle scans of different number of TRs
fd=zeros(n,1);

%% Read data 

k=0;
for ix=1:n
    for i=1:1 %legacy for loop
        k=k+1;
%         try
%             fullfilepath_mov_reg=[FD(ix).Movement_Regressors_file_and_path{i}];
%         catch
%             fullfilepath_mov_reg=[FD(ix).Movement_Regressors_path{i} f file_mov_reg];
%         end
        
        fullfilepath_mov_reg=path_filename_mov_reg_file{k};
        
%         MR = importMovReg(fullfilepath_mov_reg);
        MR = importMovReg_patch(fullfilepath_mov_reg);
        
        % start hack
%         local_n=size(MR,1);
%         frames_per_segment=floor(local_n/segments(2));
%         local_from=1:frames_per_segment:local_n;
%         local_to=frames_per_segment:frames_per_segment:local_n;
%         local_from=local_from(segments(1));
%         local_to=local_to(segments(1));
%         MR=MR(local_from:local_to,:);
        % done hack
        
        
        MR_ld=make_friston_regressors(MR);%% Using this function to only get the linear displacements
        MR_ld=MR_ld(:,1:6);
        frames(k)=size(MR,1);
        mov_cell{k}=detrend(MR_ld);
        
        
        FD=calc_FD_HCP(fullfilepath_mov_reg);
        ix_FD=1:frames(k);        
        
        fd(k)=mean(FD);
    end
end

[B I]=sort(fd,'ascend');

% If traces of different length are provided, it will truncate to the
% shortest time
min_frames=min(frames);
mov=zeros(n,min_frames,6);


k=0;
for ix=1:n
    for i=1:1 %legacy for loop
        k=k+1;
        temp_data=mov_cell{k};
        mov(k,:,:)=temp_data(1:min_frames,:);
    end
end


local_n=size(mov,2);
frames_per_segment=floor(local_n/segments(2));
local_from=1:frames_per_segment:local_n;
local_to=frames_per_segment:frames_per_segment:local_n;
local_from=local_from(1:segments(end));
local_to=local_to(1:segments(end));
%% Calculate power and Make figure
my_color=fig_settings.palette1;
fs_title=fig_settings.fs_title;
fs_axis=fig_settings.fs_axis;
fs_legend=fig_settings.fs_legend;
fs_label=fig_settings.fs_label;
fig_wide=fig_settings.fig_wide;
fig_tall=fig_settings.fig_tall;

tit{1}='x';
tit{2}='y';
tit{3}='z';
tit{4}='\theta_x';
tit{5}='\theta_y';
tit{6}='\theta_z';


tit_figure=[tit_preffix 'cat_mov_reg_power_N_' num2str(n) '_unique_scans'];
tit_figure=[tit_figure '_segment_' num2str(segments(1)) '_out_of_' num2str(segments(2))];
h = figure('Visible','on',...
    'Units','centimeters',...
    'PaperUnits','centimeters',...
    'name',tit_figure,...
    'Position',[8 1 fig_wide fig_tall],...
    'PaperPosition',[8 1 fig_wide fig_tall],...
    'color',fig_settings.fig_color);


if CLIM_provided_flag==0
    CLIM=zeros(6,2);
end


order=1;
if ix_subject_scan_provided_flag==0
    ix_subject_scan=I;
    MU=zeros(6,length(I));
    SIGMA=zeros(6,length(I));
    P=zeros(6,length(I),order+1);
end


for i=1:6
    subplot(1,6,i)
%     [y,x]=pmtm(squeeze(mov(:,:,i))',8,[],1/TR);
%     y=y(:,ix_subject_scan);
%     y=10*log10(y);
    
    % start hack
    [y_init,x]=pmtm(squeeze(mov(:,local_from(1):local_to(1),i))',8,[],1/TR);
    [y_end,x]=pmtm(squeeze(mov(:,local_from(end):local_to(end),i))',8,[],1/TR);
    
    y=10*log(y_end)-10*log(y_init);
    
%     y=y>0;
    % end hack
    %         y=log(y);
    %     Y=zscore(y(:,I),[],1)';
    if ix_subject_scan_provided_flag==0
        [Y, mu, sigma]=zscore(y,[],1);
        MU(i,:)=mu;
        SIGMA(i,:)=sigma;
        for j=1:length(I)
            P(i,j,:)=polyfit(y(:,j),Y(:,j),order);
        end
    else
        mu=MU(i,:);
        sigma=SIGMA(i,:);
        Y=y;
        Y=(Y-mu)./sigma;
        for j=1:length(I)
            Y(:,j)=polyval(squeeze(P(i,j,:)),y(:,j));
        end
        
    end
    %     [Y, mu, sigma]=zscore(y(:,ix_subject_scan),[],1);
    Y=Y';
    Y=y';
    %     MU{i}=mu;
    %     SIGMA{i}=sigma;
    %         ylims=prctile(Y(:),fig_settings.saturation);
    if CLIM_provided_flag==1
        ylims=CLIM(i,:);
    else
        ylims=prctile(Y(:),fig_settings.saturation);
        CLIM(i,:)=ylims;
        
    end
    %         ylims=prctile(Y(:),fig_settings.saturation);
    imagesc(x,[],Y,ylims)
    title(tit{i},'fontsize',fs_title)
    if i>1
        set(gca,'ytick',[])
    else
        
        temp_ticks=get(gca,'ytick');
        if length(temp_ticks)>length(B)
            set(gca,'ytick',1:length(B));
            set(gca,'yticklabel',num2str(B,'%4.2f'))
        else
            
            set(gca,'yticklabel',num2str(B(get(gca,'ytick')),'%4.2f'))
        end
        ylabel('Mean FD (mm)','fontsize',fs_label,'color','k')
    end
    xlabel('Freq. (Hz)','fontsize',fs_label,'color','k')
    set(gca,'fontsize',fs_axis);
    set(gca,'xticklabel',num2str(get(gca,'xtick')','%4.1f'));
    
    if ix_subject_scan_provided_flag==1
        set(gca,'yticklabel',[])
        ylabel([''])
    end
        colorbar
    
end
colormap jet

barh=linspace(fig_settings.saturation(1),fig_settings.saturation(2),100);
pos=get(gca,'position');


left_over=1-(pos(1)+pos(3));
bar_pos=[1-2*left_over/3 pos(2) left_over/5 pos(4)];

subplot('position',bar_pos)
imagesc([],barh,barh')
set(gca,'xtick',[])
set(gca,'ydir','normal')
set(gca,'YAxisLocation','right');
set(gca,'fontsize',fig_settings.fs_axis)
xlabel({'%',' power'})
%%

fig_name=tit_figure;
saveas(gcf,fig_name)
print(fig_name,'-dpng','-r300')
print(fig_name,'-dtiffn','-r300')