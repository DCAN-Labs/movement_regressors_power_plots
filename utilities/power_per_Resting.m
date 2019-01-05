function CLIM=power_per_Resting(path_filename_mov_reg_file,TR,varargin)

%% Oscar Miranda-Dominguez

%%

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
                        
        case 'tit_preffix'
            tit_preffix=varargin{q+1};
            q = q+1;
            
        case 'pmu_path'
            PMU_path=varargin{q+1};
            q = q+1;
            
        otherwise
            disp(['Unknown option ',varargin{q}])
    end
    q = q+1;
end
%%

f=filesep;

tit{1}='x';
tit{2}='y';
tit{3}='z';
tit{4}='\theta_x';
tit{5}='\theta_y';
tit{6}='\theta_z';

ylab{1}='Time';
ylab{2}='Time';
ylab{3}='Spectrum';
ylab{4}='Coherence';


my_color=fig_settings.palette1;
fs_title=fig_settings.fs_title;
fs_axis=fig_settings.fs_axis;
fs_legend=fig_settings.fs_legend;
fs_label=fig_settings.fs_label;

time_lapse=[120 130];

window=10;
noverlap=8;
% f=[];
fs=1./TR;
%%
fig_wide=20;
fig_tall=10;


%%

Nyqusit=(1./TR)/2;
delta=10;
%runs=FD(ix).runs;% legacy from original function
runs=1;

if length(TR)==1 %added Jan 24
    TR=repmat(TR,runs,1);
    Nyqusit=repmat(Nyqusit,runs,1);
end

if nargin<6
    CLIM=zeros(runs,3,6,2,2);
    CLIM_provided_flag=0;
else
    CLIM_provided_flag=1;
end
% Dimensions:
% 1: Individual run
% 2: row from each panel
% 3: each one of the 6 DOF
% 4: min max y axis
% 5: left | right axis


tit_figure=cell(runs,1);


%%
k=0;
lw=3;
lw_physio=2;
%% sec1

%% sec2
k=0;
lw=3;
lw_physio=2;

RRa_Hz=zeros(runs,1);
HRa_Hz=zeros(runs,1);
RR_Hz=zeros(runs,1);
HR_Hz=zeros(runs,1);
r=cell(runs,1);
h=cell(runs,1);
R=cell(runs,1);
H=cell(runs,1);
fR=cell(runs,1);
fH=cell(runs,1);
tr=cell(runs,1);
th=cell(runs,1);
xf=cell(runs,1);
yfs=cell(runs,1);
xfh=cell(runs,1);
yfsh=cell(runs,1);
rd=cell(runs,1);
td=cell(runs,1);
hd=cell(runs,1);
thd=cell(runs,1);
m=zeros(runs,1);
mh=zeros(runs,1);

% mr_ld=zeros(FD(ix).frames_per_run(1)+1,6,runs);

for i=1:runs
%     tit_figure{i}=[tit_preffix 'Fig02_REST' num2str(i) '_' char(FD(ix).SubjID)];
    tit_figure{i}=[tit_preffix 'power_per_Resting_TR_' num2str(1000*TR(i))];
    
    fullfilepath_mov_reg=path_filename_mov_reg_file;

    
    try
        [RRa_Hz(i), HRa_Hz(i),RR_Hz(i), HR_Hz(i)]=read_aliased_PMUextracted(FD(ix).PMU_path{i},TR(i));
    end
    
    
%     MR = importMovReg(fullfilepath_mov_reg);
    MR = importMovReg_patch(fullfilepath_mov_reg);
    MR_ld=make_friston_regressors(MR);%% Using this function to only get the linear displacements
    MR_ld=MR_ld(:,1:6);

    mr_ld(:,:,i)=MR_ld;
    t=0:size(MR_ld,1)-1;
    t=t*TR(i);
    
    try
        load(PMU_path);
        r{i}=PMUstructmat.respiration(:,2);
        h{i}=PMUstructmat.pulse(:,2);
        tr{i}=(0:length(r{i})-1)/PMUstructmat.resprate;
        th{i}=(0:length(h{i})-1)/PMUstructmat.pulsrate;
        [R{i}, fR{i}]=pmtm(detrend(r{i}),30,[],PMUstructmat.resprate);
        [H{i}, fH{i}]=pmtm(detrend(h{i}),30,[],PMUstructmat.pulsrate);
        
        
        downsampling_factor=TR(i)*PMUstructmat.resprate;
        rd{i}=downsample(r{i},downsampling_factor);
        td{i}=downsample(tr{i},downsampling_factor);
        m(i)=min(length(t),length(td{i}));
        
        data2=detrend(rd{i}(1:m(i)));
        [yf, xf{i}]=pmtm(detrend(data2),5,[],1/TR(i));
        yfs{i}=smooth(yf,3);
%         yfs{i}=yf;
%         yfs{i}=yf; %debug
        [foo I]=max(yfs{i});
        RRa_Hz(i)=xf{i}(I);
        
        %% Repeat for HR
        
        downsampling_factor=TR(i)*PMUstructmat.pulsrate;
        hd{i}=downsample(h{i},downsampling_factor);
        thd{i}=downsample(th{i},downsampling_factor);
        mh(i)=min(length(t),length(thd{i}));
        
        data2=detrend(hd{i}(1:mh(i)));
        [yf, xfh{i}]=pmtm(detrend(data2),5,[],1/TR(i));
        yfsh{i}=smooth(yf,10);
        [foo I]=max(yfsh{i});
        HRa_Hz(i)=xfh{i}(I);
    end
    
    %     for j=1:6
    %         [y,x]=pmtm(detrend(mr_ld(:,j,i)),5,[],1/TR);
    %     end
end
%%
%%

%%

window=10;
noverlap=8;
for i=1:runs
    h = figure('Visible','on',...
        'Units','centimeters',...
        'PaperUnits','centimeters',...
        'name',tit_figure{i},...
        'Position',[8 1 fig_wide fig_tall],...
        'PaperPosition',[8 1 fig_wide fig_tall],...
        'color',fig_settings.fig_color);
    
    k=0;
    
    for j=1:6
        k=k+1;
        
%         subplot(3,6,k)
        subplot(3,6,k+6)
        yyaxis left
        plot(td{i},rd{i},...
            'linewidth',lw_physio,...
            'color',[1 1 1]*.7)
        set(gca,'yticklabel',[])
        try
            xlim([0 td{i}(m(i))])
        catch
            xlim(t([1 end]))
        end
        if j==1
            ylabel({'Time',['Rest ' num2str(i)]},'fontsize',fs_label,'color','k')
        end
        if CLIM_provided_flag==1
            ylims=CLIM(i,1,j,:,1);
        else
            ylims=ylim;
            CLIM(i,1,j,:,1)=ylims;
        end
        ylim(ylims)
        
        
        yyaxis right
        plot(t,mr_ld(:,j,i),...
            'color',my_color(j,:),...
            'linewidth',lw)
        title(tit{j},'fontsize',fs_title)
        
        set(gca,'yticklabel',[])
        set(gca,'xtick',time_lapse)
        xlim(time_lapse)
        set(gca,'fontsize',fs_axis);
        if CLIM_provided_flag==1
            ylims=CLIM(i,1,j,:,2);
        else
            ylims=ylim;
            CLIM(i,1,j,:,2)=ylims;
        end
        ylim(ylims)
        xlabel('Time (s)','fontsize',fs_label)
        
        
        
        
%         subplot(3,6,k+6)
        subplot(3,6,k)
        yyaxis left
        plot(td{i},rd{i},...
            'linewidth',1,...
            'color',[1 1 1]*.7)
        set(gca,'yticklabel',[])
        try
            xlim([0 td{i}(m(i))])
        catch
            xlim(t([1 end]))
        end
        if j==1
            ylabel({'Time',['Rest ' num2str(i)]},'fontsize',fs_label,'color','k')
        end
        if CLIM_provided_flag==1
            ylims=CLIM(i,2,j,:,1);
        else
            ylims=ylim;
            CLIM(i,2,j,:,1)=ylims;
        end
        ylim(ylims)
        
        yyaxis right
        plot(t,mr_ld(:,j,i),...
            'color',my_color(j,:),...
            'linewidth',lw)
        set(gca,'yticklabel',[])
        try
            xlim([0 td{i}(m(i))])
        catch
            xlim(t([1 end]))
        end
        
        set(gca,'fontsize',fs_axis);
        if length(xticks)>4
        try
            set(gca,'xtick',0:120:t(m(i)))
        catch
            set(gca,'xtick',0:120:t(end))
        end
        end
        xlabel('Time (s)','fontsize',fs_label)
%         if CLIM_provided_flag==1
%             ylims=CLIM(i,2,j,:,2);
%         else
%             ylims=ylim;
%             CLIM(i,2,j,:,2)=ylims;
%         end
%         ylim(ylims)
        
        subplot(3,6,k+12)
        yyaxis left
        plot(xf{i},yfs{i},'color',[1 1 1]*.7,'linewidth',lw_physio)
        set(gca,'yticklabel',[])
        if j==1
            ylabel({'Spectrum',['Rest ' num2str(i)]},'fontsize',fs_label,'color','k')
        end
        
        
        yyaxis right
        [y,x]=pmtm(detrend(mr_ld(:,j,i)),[],[],1/TR(i));
        plot(x,10*log10(y),...
            'color',my_color(j,:),...
            'linewidth',lw)
        set(gca,'yticklabel',[])
        axis tight
%         if CLIM_provided_flag==1
%             ylims=CLIM(i,3,j,:,1);
%         else
%             ylims=ylim;
%             CLIM(i,3,j,:,1)=ylims;
%         end
%         ylim(ylims)
        
%         set(gca,'xtick',0:.2:Nyqusit(i));
        set(gca,'fontsize',fs_axis);
        xlabel('Freq. (Hz)','fontsize',fs_label,'color','k')
%         set(gca,'xticklabel',num2str(get(gca,'xtick')','%4.1f'));
%         if CLIM_provided_flag==1
%             ylims=CLIM(i,3,j,:,2);
%         else
%             ylims=ylim;
%             CLIM(i,3,j,:,2)=ylims;
%         end
%         ylim(ylims)
        
        
        %          subplot(3,6,k+18)
        %         data1=detrend(mr_ld(1:m(i),j,i));
        %         data2=detrend(rd{i}(1:m(i)));
        %         [cxy,f] = mscohere(data1,data2,window,noverlap,f,fs);
        %         plot(f,cxy,'k','linewidth',lw)
        %         set(gca,'yticklabel',[])
        %         axis tight
        %
        %         set(gca,'xtick',0:.2:Nyqusit);
        %         set(gca,'fontsize',fs_axis);
        %         if j==1
        %         ylabel({'Coherence',['Rest ' num2str(i)]},'fontsize',fs_label,'color','k')
        %         end
        
        
        
    end
    fig_name=tit_figure{i};
    saveas(gcf,fig_name)
    print(fig_name,'-dpng','-r300')
    print(fig_name,'-dtiffn','-r300')
end


function scaled_y=scale_y(xx,yy,yl,delta,Nyqusit)

local_ix=find(xx>=Nyqusit,1);

scaled_y=10*log10(yy);

minyy=min(scaled_y(1:local_ix));
scaled_y=scaled_y-minyy;

maxyy=max(scaled_y(1:local_ix));
scaled_y=scaled_y/maxyy;
scaled_y=scaled_y*delta*.9+(yl(1)-delta);

