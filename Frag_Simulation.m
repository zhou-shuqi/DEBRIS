% This is the code for No Alex FRET traces that contain only two channels.
% This code simulates 7 categories of fragments. Numbers are used to represent different categories.
    % -4（"Acceptor appear"）: Appearance of acceptor, resulting in sudden appearance of acceptor and decrease of donor signal. 
    % -3（"Donor appear"）Appearance of donor resulting in sudden appearance of both donor and acceptor signals. 
    % 0 (Non-FRET): Acceptor intensity is 0 and donor intensity is 0 or 1. 
    % 1 (FRET): Stable FRET. 
    % 2（"FRET"）: Transient FRET."FRET
    % 3（"Donor disappear"）: Donor bleaching resulting in sudden disappearance of both donor and acceptor signals. 
    % 4（"Acceptor disappear"）：Bleaching of the acceptor leads to sudden disappearance of the acceptor and increase of the donor signal.
    % 100 ("Junk"): Noisy traces.

clear
tic
timec=cputime;
N = 2000; % Approximate number of total simulated traces for training, typically 10E6
Nval= 200; % Approximate number of total simulated traces for validation, typically 2E5
le = 10; % Length of fragments
Isnr=8; % 1/Isnr is the Gaussian noise of the intensity, normally Isnr is set to 8.
Bsnr=10; % 1/Bsnr is the Gaussian noise of the background, usually Bsnr is set to 10.
FRETcorr=3; % FRET correction of two channels
N=floor(N/20);Nval=floor(Nval/20);

Tracetrain={};
Tracecat=[];
TracetrainVal={};
TracecatVal=[];

% simulated class 0 ("Non-FRET") for training
for i=1:N
    if rand < 0.5
        temptrace=normrnd(0,1/Bsnr,2,le) ;
    else
        FRET=rand*0.1;
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le) ;
        temptrace(2,:)=normrnd(FRET,1/Bsnr,1,le) ;
        temptrace2=noise(temptrace,le);
        Tracetrain(end+1,1)={temptrace2};
        Tracecat(end+1,1)=999;
    end
    Tracetrain(end+1,1)={temptrace};
    Tracecat(end+1,1)=0;

    if rand < 0.5
        temptrace=normrnd(0,1/Bsnr,2,le) ;
        temptrace1=sinnoise(temptrace,le);
    else
        FRET=rand*0.1;
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le) ;
        temptrace(2,:)=normrnd(FRET,1/Bsnr,1,le) ;
        temptrace1=sinnoise(temptrace,le);
    end
    Tracetrain(end+1,1)={temptrace1};
    Tracecat(end+1,1)=100;
end
% simulated class 0 ("Non-FRET") for validation
for i=1:Nval
    if rand < 0.5
        temptrace=normrnd(0,1/Bsnr,2,le) ;
    else
        FRET=rand*0.1;
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le) ;
        temptrace(2,:)=normrnd(FRET,1/Bsnr,1,le) ;

        temptrace2=noise(temptrace,le);
        TracetrainVal(end+1,1)={temptrace2};
        TracecatVal(end+1,1)=999;
    end
    TracetrainVal(end+1,1)={temptrace};
    TracecatVal(end+1,1)=0;

    if rand < 0.5
        temptrace=normrnd(0,1/Bsnr,2,le) ;
        temptrace1=sinnoise(temptrace,le);
    else
        FRET=rand*0.1;
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le) ;
        temptrace(2,:)=normrnd(FRET,1/Bsnr,1,le) ;
        temptrace1=sinnoise(temptrace,le);
    end
    TracetrainVal(end+1,1)={temptrace1};
    TracecatVal(end+1,1)=100;
end

% Simulated class 1 and class 2 ("FRET")
    % Two FRET states are introduced into the simulation
    % The difference of their FRET values is 0.3 or less is set as class 1,
    % The other fragments are set as class 2.

for F1=0.3:0.1:1
    for F2=F1:0.1:1
        % Simulated class 1 and class 2 ("FRET") for training
        for i=1:floor(N/5)
            t1=round(rand*3)+3;t2=round(rand*3)+3;
            Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
                1/t2 1-1/t2];
            Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
                (1-F2) 1/Isnr F2 1/Isnr];
            [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
            Tracetrain(end+1,1)={temptrace};
            if abs(F2-F1)> 0.3
                Tracecat(end+1,1)=tempstate+1;
            else
                Tracecat(end+1,1) = 1;
            end

            [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
            temptrace1=sinnoise(temptrace,le);
            Tracetrain(end+1,1)={temptrace1};
            Tracecat(end+1,1)=tempstate+101;

            if rand<0.5  
                temptrace2=noise(temptrace,le);
                Tracetrain(end+1,1)={temptrace2};
                Tracecat(end+1,1)=999;
            end
        end
        % Simulated class 1 and class 2 ("FRET") for validation
        for i=1:floor(Nval/5)
            t1=round(rand*3)+3;t2=round(rand*3)+3;
            Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
                1/t2 1-1/t2];
            Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
                (1-F2) 1/Isnr F2 1/Isnr];
            [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
            TracetrainVal(end+1,1)={temptrace};
            if abs(F2-F1)> 0.3
                TracecatVal(end+1,1)=tempstate+1;
            else
                TracecatVal(end+1,1) = 1;
            end

            [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
            temptrace1=sinnoise(temptrace,le);
            TracetrainVal(end+1,1)={temptrace1};
            TracecatVal(end+1,1)=tempstate+101;

            if rand<0.5 
                temptrace2=noise(temptrace,le);
                TracetrainVal(end+1,1)={temptrace2};
                TracecatVal(end+1,1)=999;
            end
        end
    end
end

% Simulated class 3 ("Donor disappear") and class -3 ("Donor appear") for training
for i=1:N
    FRET=round(rand*10)*0.1+0.0;
    bleacht=round(rand*(le-4))+2;
    % class 3
    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.8+0.2;F2=rand*0.8+0.2;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    bleachtemp=rand*0.6+0.2;
    temptrace(:,bleacht+2:10)=normrnd(0,1/Bsnr,2,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    Tracetrain(end+1,1)={temptrace};
    Tracecat(end+1,1)=3;

    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.8+0.2;F2=rand*0.8+0.2;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(:,bleacht+2:10)=normrnd(0,1/Bsnr,2,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace1=sinnoise(temptrace,le);
    Tracetrain(end+1,1)={temptrace1};
    Tracecat(end+1,1)=103;

    if rand<0.5
        temptrace=temptrace1;
    end

    % class -3
    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.8+0.2;F2=rand*0.8+0.2;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(:,bleacht+2:10)=normrnd(0,1/Bsnr,2,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace=temptrace(:,end:-1:1);
    Tracetrain(end+1,1)={temptrace};
    Tracecat(end+1,1)=-3;

    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.8+0.2;F2=rand*0.8+0.2;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(:,bleacht+2:10)=normrnd(0,1/Bsnr,2,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace1=sinnoise(temptrace,le);
    temptrace1=temptrace1(:,end:-1:1);
    Tracetrain(end+1,1)={temptrace1};
    Tracecat(end+1,1)=103;

    if rand<0.5
        temptrace=temptrace1;
    end
end
% Simulated class 3 ("Donor disappear") and class -3 ("Donor appear") for training
for i=1:Nval
    FRET=round(rand*10)*0.1+0.0;
    bleacht=round(rand*(le-4))+2;
    % class 3
    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.8+0.2;F2=rand*0.8+0.2;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    bleachtemp=rand*0.6+0.2;
    temptrace(:,bleacht+2:10)=normrnd(0,1/Bsnr,2,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    TracetrainVal(end+1,1)={temptrace};
    TracecatVal(end+1,1)=3;

    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.8+0.2;F2=rand*0.8+0.2;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(:,bleacht+2:10)=normrnd(0,1/Bsnr,2,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace1=sinnoise(temptrace,le);
    TracetrainVal(end+1,1)={temptrace1};
    TracecatVal(end+1,1)=103;

    if rand<0.5
        temptrace=temptrace1;
    end

    % class -3
    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.8+0.2;F2=rand*0.8+0.2;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(:,bleacht+2:10)=normrnd(0,1/Bsnr,2,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace=temptrace(:,end:-1:1);
    TracetrainVal(end+1,1)={temptrace};
    TracecatVal(end+1,1)=-3;

    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.8+0.2;F2=rand*0.8+0.2;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(:,bleacht+2:10)=normrnd(0,1/Bsnr,2,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace1=sinnoise(temptrace,le);
    temptrace1=temptrace1(:,end:-1:1);
    TracetrainVal(end+1,1)={temptrace1};
    TracecatVal(end+1,1)=103;

    if rand<0.5
        temptrace=temptrace1;
    end
end

% Simulated class 4("Acceptor disappear") and class -4("Acceptor appear") for training
for i=1:N
    FRET=round(rand*7)*0.1+0.3;
    bleacht=round(rand*(le-4))+2;
    cross=rand*0.15-0.05;
    %class 4
    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.7+0.3;F2=rand*0.7+0.3;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    bleachtemp=rand*0.6+0.2;
    temptrace(1,bleacht+2:10)=normrnd(1-cross,1/Isnr,1,10-bleacht-1) ;
    temptrace(2,bleacht+2:10)=normrnd(cross,1/Bsnr,1,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    Tracetrain(end+1,1)={temptrace};
    Tracecat(end+1,1)=4;

    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.7+0.3;F2=rand*0.7+0.3;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(1,bleacht+2:10)=normrnd(1-cross,1/Isnr,1,10-bleacht-1) ;
    temptrace(2,bleacht+2:10)=normrnd(cross,1/Bsnr,1,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace1=sinnoise(temptrace,le);
    Tracetrain(end+1,1)={temptrace1};
    Tracecat(end+1,1)=104;

    if rand<0.5
        temptrace=temptrace1;
    end

    % class -4
    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.7+0.3;F2=rand*0.7+0.3;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(1,bleacht+2:10)=normrnd(1-cross,1/Isnr,1,10-bleacht-1) ;
    temptrace(2,bleacht+2:10)=normrnd(cross,1/Bsnr,1,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace=temptrace(:,end:-1:1);
    Tracetrain(end+1,1)={temptrace};
    Tracecat(end+1,1)=-4;

    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.7+0.3;F2=rand*0.7+0.3;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(1,bleacht+2:10)=normrnd(1-cross,1/Isnr,1,10-bleacht-1) ;
    temptrace(2,bleacht+2:10)=normrnd(cross,1/Bsnr,1,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace1=sinnoise(temptrace,le);
    temptrace1=temptrace1(:,end:-1:1);
    Tracetrain(end+1,1)={temptrace1};
    Tracecat(end+1,1)=104;

    if rand<0.5
        temptrace=temptrace1;
    end
end
% Simulated class 4("Acceptor disappear") and class -4("Acceptor appear") for validation
for i=1:Nval
    FRET=round(rand*7)*0.1+0.3;
    bleacht=round(rand*(le-4))+2;
    cross=rand*0.15-0.05;
    %class 4
    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.7+0.3;F2=rand*0.7+0.3;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    bleachtemp=rand*0.6+0.2;
    temptrace(1,bleacht+2:10)=normrnd(1-cross,1/Isnr,1,10-bleacht-1) ;
    temptrace(2,bleacht+2:10)=normrnd(cross,1/Bsnr,1,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    TracetrainVal(end+1,1)={temptrace};
    TracecatVal(end+1,1)=4;

    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.7+0.3;F2=rand*0.7+0.3;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(1,bleacht+2:10)=normrnd(1-cross,1/Isnr,1,10-bleacht-1) ;
    temptrace(2,bleacht+2:10)=normrnd(cross,1/Bsnr,1,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace1=sinnoise(temptrace,le);
    TracetrainVal(end+1,1)={temptrace1};
    TracecatVal(end+1,1)=104;

    if rand<0.5
        temptrace=temptrace1;
    end

    % class -4
    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.7+0.3;F2=rand*0.7+0.3;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(1,bleacht+2:10)=normrnd(1-cross,1/Isnr,1,10-bleacht-1) ;
    temptrace(2,bleacht+2:10)=normrnd(cross,1/Bsnr,1,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace=temptrace(:,end:-1:1);
    TracetrainVal(end+1,1)={temptrace};
    TracecatVal(end+1,1)=-4;

    if rand <0.2
        temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le);
        temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;
    else
        t1=round(rand*3)+3;t2=round(rand*3)+3;F1=rand*0.7+0.3;F2=rand*0.7+0.3;
        Tmatrix = [1-1/t1 1/t1; ... % transfer matrix of different state
            1/t2 1-1/t2];
        Smatrix = [1-F1 1/Isnr F1 1/Isnr;... % signal and noise of D and A of state I and so on
            (1-F2) 1/Isnr F2 1/Isnr];
        [temptrace tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2);
    end
    temptrace(1,bleacht+2:10)=normrnd(1-cross,1/Isnr,1,10-bleacht-1) ;
    temptrace(2,bleacht+2:10)=normrnd(cross,1/Bsnr,1,10-bleacht-1) ;
    temptrace(:,bleacht+1)=temptrace(:,bleacht)*bleachtemp+temptrace(:,bleacht+2)*(1-bleachtemp);
    temptrace1=sinnoise(temptrace,le);
    temptrace1=temptrace1(:,end:-1:1);
    TracetrainVal(end+1,1)={temptrace1};
    TracecatVal(end+1,1)=104;

    if rand<0.5
        temptrace=temptrace1;
    end
end

% Simulated extra class 999 ("Junk") for training
for i=1:N
    temptrace=rand(2,le) ;
    Tracetrain(end+1,1)={temptrace};
    Tracecat(end+1,1)=999;

    FRET=0.5*rand;
    temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le) ;
    temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;

    temptime=round(rand*4)+3;
    if rand<0.5
        temptrace(1,1:temptime)=temptrace(1,1:temptime)/(1.5+1.5*rand);
    else
        temptrace(1,temptime+1:end)=temptrace(1,temptime+1:end)/(1.5+1.5*rand);
    end
    Tracetrain(end+1,1)={temptrace};
    Tracecat(end+1,1)=999;

    FRET=0.5*rand+0.5;
    temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le) ;
    temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;

    temptime=round(rand*4)+3;
    if rand<0.5
        temptrace(2,1:temptime)=temptrace(2,1:temptime)/(1.5+1.5*rand);
    else
        temptrace(2,temptime+1:end)=temptrace(2,temptime+1:end)/(1.5+1.5*rand);
    end
    Tracetrain(end+1,1)={temptrace};
    Tracecat(end+1,1)=999;

end
% Simulated extra class 999 ("Junk") for validation
for i=1:Nval
    temptrace=rand(2,le) ;
    TracetrainVal(end+1,1)={temptrace};
    TracecatVal(end+1,1)=999;

    FRET=0.5*rand;
    temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le) ;
    temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;

    temptime=round(rand*4)+3;
    if rand<0.5
        temptrace(1,1:temptime)=temptrace(1,1:temptime)/(1.5+1.5*rand);
    else
        temptrace(1,temptime+1:end)=temptrace(1,temptime+1:end)/(1.5+1.5*rand);
    end
    TracetrainVal(end+1,1)={temptrace};
    TracecatVal(end+1,1)=999;

    FRET=0.5*rand+0.5;
    temptrace(1,:)=normrnd(1-FRET,1/Isnr,1,le) ;
    temptrace(2,:)=normrnd(FRET,1/Isnr,1,le) ;

    temptime=round(rand*4)+3;
    if rand<0.5
        temptrace(2,1:temptime)=temptrace(2,1:temptime)/(1.5+1.5*rand);
    else
        temptrace(2,temptime+1:end)=temptrace(2,temptime+1:end)/(1.5+1.5*rand);
    end
    TracetrainVal(end+1,1)={temptrace};
    TracecatVal(end+1,1)=999;
end

Tracecat(Tracecat>100 & Tracecat<900) = 100;
TracecatVal(TracecatVal>100 & TracecatVal<900) = 100;
tempnumber=size(Tracecat,1);
tempi=find(((Tracecat == 100) & (rand(tempnumber,1)>0.25))==1);
Tracecat(tempi)=[];
Tracetrain(tempi)=[];
tempnumber=size(Tracecat,1);
tempi=find(((Tracecat == 999) & (rand(tempnumber,1)>0.5))==1);
Tracecat(tempi)=[];
Tracetrain(tempi)=[];
tempnumber=size(Tracecat,1);

% introduce FRET correction factor for class 2, 3, 4
for i=tempnumber:-1:1
    A=cell2mat(Tracetrain(i));
    if abs(Tracecat(i))>1 && abs(Tracecat(i))<5
        A(:,1)=A(:,1)+(rand-0.5)/5*mean(A(:,1));
        A(:,2)=A(:,2)+(rand-0.5)/5*mean(A(:,2));
        A=A*(rand*0.4+0.8);
        if rand < 1/2
            A(1,:)=A(1,:)*exp((rand*2-1)*log(FRETcorr));
        else
            A(2,:)=A(2,:)*exp((rand*2-1)*log(FRETcorr));
        end
    elseif Tracecat(i)==0
        A(:,1)=A(:,1)+(rand-0.5)/5*mean(A(:,1));
        A(:,2)=A(:,2)+(rand-0.5)/5*mean(A(:,2));
        A=A*(rand*0.4+0.8);
    elseif Tracecat(i)==1
        A(:,1)=A(:,1)+(rand-0.5)/5*mean(A(:,1));
        A(:,2)=A(:,2)+(rand-0.5)/5*mean(A(:,2));
        A=A*(rand*0.4+0.8);
    end
    Tracetrain(i)={A};
end

tempnumber=size(TracecatVal,1);
tempi=find(((TracecatVal == 100) & (rand(tempnumber,1)>0.25))==1);
TracecatVal(tempi)=[];
TracetrainVal(tempi)=[];
tempnumber=size(TracecatVal,1);
tempi=find(((TracecatVal == 999) & (rand(tempnumber,1)>0.5))==1);
TracecatVal(tempi)=[];
TracetrainVal(tempi)=[];

tempnumber=size(TracecatVal,1);
for i=tempnumber:-1:1
    A=cell2mat(TracetrainVal(i));
    if abs(TracecatVal(i))>1 && abs(TracecatVal(i))<5
        A(:,1)=A(:,1)+(rand-0.5)/5*mean(A(:,1));
        A(:,2)=A(:,2)+(rand-0.5)/5*mean(A(:,2));
        A=A*(rand*0.4+0.8);
        if rand < 1/2
            A(1,:)=A(1,:)*exp((rand*2-1)*log(FRETcorr));
        else
            A(2,:)=A(2,:)*exp((rand*2-1)*log(FRETcorr));
        end
    elseif TracecatVal(i)==0
        A(:,1)=A(:,1)+(rand-0.5)/5*mean(A(:,1));
        A(:,2)=A(:,2)+(rand-0.5)/5*mean(A(:,2));
        A=A*(rand*0.4+0.8);
    elseif TracecatVal(i)==1
        A(:,1)=A(:,1)+(rand-0.5)/5*mean(A(:,1));
        A(:,2)=A(:,2)+(rand-0.5)/5*mean(A(:,2));
        A=A*(rand*0.4+0.8);
    end
       TracetrainVal(i)={A};
end

Tracecat(Tracecat>100) = 100;
TracecatVal(TracecatVal>100) = 100;

Tracecat = categorical(Tracecat);
TracecatVal = categorical(TracecatVal);
cputime-timec
toc
%% function to simulate traces containing two FRET state
function [temptrace,tempstate]=simultracef(le,Tmatrix,Smatrix,t1,t2)
    state = zeros(1, le);
    state(1) = 1+double(rand<=(t1/(t1+t2)));
    for t = 1:le-1
        state(t+1) = find(rand <= cumsum(Tmatrix(state(t),:)), 1);
    end
    state(1)=state(2);state(end)=state(end-1);
    if min(state) == max(state)
        tempstate=0;
    else
        tempstate=1;
    end
    temptrace = zeros(2, le);
    for s=1:size(Tmatrix,1)
        temptrace(1,state==s)=normrnd(Smatrix(s,1),Smatrix(s,2),1,size(find(state==s),2));
        temptrace(2,state==s)=normrnd(Smatrix(s,3),Smatrix(s,4),1,size(find(state==s),2));
    end
end
%% function to introduce noise in sin wave shape
function temptrace1=sinnoise(temptrace,le)
tracenoise=sin(pi*((1:le)/(rand*1+1.5)/le+rand));
tracenoise=tracenoise-mean(tracenoise(:));
tracenoise=tracenoise/max(abs(tracenoise(:)));
tracenoise2=2*(rand*0.3+0.35)*tracenoise+rand-0.5;

tracenoise=sin(pi*((1:le)/(rand*1+1.5)/le+rand));
tracenoise=tracenoise-mean(tracenoise(:));
tracenoise=tracenoise/max(abs(tracenoise(:)));
tracenoise=2*(rand*0.3+0.35)*tracenoise+rand-0.5;
state=rand;
temptrace1=temptrace;
if state <= 1/3
    temptrace1(1,:)=temptrace1(1,:)+tracenoise;
elseif state >1/3 && state <=2/3
    temptrace1(2,:)=temptrace1(2,:)+tracenoise2;
elseif state >2/3
    temptrace1(2,:)=temptrace1(2,:)+tracenoise;
    temptrace1(1,:)=temptrace1(1,:)+tracenoise2;
end
end
%% function to introduce noise in square wave shape
function temptrace2=noise(temptrace,le)
tempnoise=zeros(2,le);
temptime=round(9*rand(1,2))+1;
while abs(temptime(1)-temptime(2))<3 && abs(temptime(1)-temptime(2))>7
    temptime=round(9*rand(1,2))+1;
end
tempnoise(:,min(temptime):max(temptime))=(rand(2,max(temptime)+1-min(temptime))*0.01+1)*(round(rand)*2-1)*(rand+0.5);
tempnoise(1,:)=tempnoise(1,:)-mean(tempnoise(1,:));
tempnoise(2,:)=tempnoise(2,:)-mean(tempnoise(2,:));

state=rand;
temptrace2=temptrace;
if state <= 1/4
    temptrace2(1,:)=temptrace2(1,:)+tempnoise(1,:);
elseif state >1/4 && state <=1/2
    temptrace2(2,:)=temptrace2(2,:)+tempnoise(2,:);
elseif state >1/2 && state <=3/4
    temptrace2=temptrace(1,:);
    temptrace2(2,:)=temptrace(2,:)+(round(rand)*2-1)*(rand*0.5+0.25);
elseif state >3/4 && state <=1
    temptrace2=temptrace(1,:)+(round(rand)*2-1)*(rand*0.5+0.25);
    temptrace2(2,:)=temptrace(2,:);
end
end
%% delete
function plot
figure;
hdl3=gcf;
tempnumber=size(Tracecat,1);
for i=tempnumber:-1:1
    if Tracecat(i) == 2
        i
        A=cell2mat(Tracetrain(i));
        figure(hdl3);
        plot(1:le,A(1,:),'g',1:le,A(2,:),'b');%,time,stdev,'r');
        grid on;
        zoom on;
        reply=input('return to continue, f for fret, c for co-locol, b to go back ','s');
    end
end
end

