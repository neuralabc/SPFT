%% Read data directly from the Presentation log file
% more comprehensive data, allows for all of the same computations after
% downsampling (or upsampling the target curves :)
% This is the version that works properly, as of May, 2015
% modified so that multiple days of data can be read into the same
% structure,

% XXX EACH presentation of the stimulus takes 12.5ms, for a total duration
% of 18000ms - this can be used to double-check the lag times to make sure
% that they are correct
%
% Must convert the sensor_val to the equivalent bar position with a
% combination of factors that differ depending on the maximum force that
% the participant used on each day:
% (((log_val*16)-2)*850/240/20)/factorVar (where log_val = sensor_var)
% factorVar=maximum_value*.3/190 (XXX though 170 is the number that Bettina
% used, this does not appear to be correct for our purposes here XXX)
%
%

% ========================================================================
% ***===***===***===***===***===***===***===***===***===***===***===***===
% !!IMPORTANT!!
% NOTE: YOU MUST REPLACE THE "NA" in the .log file for this to work :(
% do this on the command line, run this and then copy and paste output
% it creates a .bak file that has the original
%
% for file in *localize*log ; do cmd="sed -i.bak 's/NA//' $file" ; echo $cmd ; done
%
% ***===***===***===***===***===***===***===***===***===***===***===***===
% ========================================================================


% ========================================================================
% This data was collected with the new program (March 2015) which reports 3 differt
% values for force:
%   Maxwert_* -       max force in old sensor value (meaningless unless mapped)
%   Maxwert_8bit_* -  max force in 8bit
%   Maxwert_Kg_* -    max force of this individual in kg
%
% These values are now all searched for and added to the PPs data structure
% for each individual
%
% ========================================================================

%addpath('/home/raid1/steele/Documents/Projects/Working/7T/SPFT/scripts');
addpath('/afs/cbs.mpg.de/projects/neu009_sequencing-plasticity/scripts/bx/');
dataDir_root='/afs/cbs.mpg.de/projects/neu009_sequencing-plasticity/probands/' %specify the root location for bx data, actual subdir will differ depending on the ID

SHOWPLOTS=false;

% XXX WRITE A LOOP OVER DAYS TO SPECIFY THIS
SPFT_d0.seqLength=1440; %number of samples for the sequence length
SPFT_d0.seqDur=18; %duration of sequences (s) (NOTE: the two sequences generated from SPFT_create_sequences.m {16s,18s} are exactly the same because you calculated everything based on frequency, there is nothing to worry about)
SPFT_d0.numDays=1; %number of days of performance data that is available
SPFT_d0.numTrials=3; %trials per block
SPFT_d0.numBlocks=2; %num blocks
SPFT_d0.numConditions=2; %SMP, RST, LRN
%SPFT_d0.numConditions=1; %SMP, RST (no LRN) XXX THIS IS SUPERSEDED by the SPFT_d0.trialTypes entry
SPFT_d0.dataDir=dataDir_root;
SPFT_d0.TR=3.5; %TR, in seconds
SPFT_d0.blockDuration=67.6;  %duration of LRN and SMP blocks (RST is slightly different, as there are no breaks between sequences) - ONLY used in the creation of GLM design

SPFT_d0.totalTrials=SPFT_d0.numTrials*SPFT_d0.numBlocks*SPFT_d0.numConditions;
SPFT_d0.trialOnsetMarkerIdx=[1:SPFT_d0.seqLength+1:SPFT_d0.seqLength*SPFT_d0.totalTrials]; %locations within input files of trial indicators (not data, just indicate the beginning of trial n)
%SPFT_d0.trialTypes=[1 1 1 2 2 2 1 1 1 1 1 1 2 2 2 1 1 1 1 1 1 2 2 2 1 1 1 1 1 1 2 2 2 1 1 1]; %1=SMP, 2=RST, 3=LRN
%SPFT_d0.trialTypes=repmat([1 1 1 2 2 2 3 3 3],1,SPFT_d0.numBlocks); %1=SMP, 2=RST, 3=LRN
SPFT_d0.trialTypes=repmat([1 1 1 2 2 2],1,SPFT_d0.numBlocks); %1=SMP, 2=RST, 3=LRN


SPFT_d0.numSMPtrials=3; %NUM TRIALS PER BLOCK
SPFT_d0.trialTypes_txt={'1=SMP', '2=RST'};
SPFT_d0.LRN=[90;90;91;91;92;92;93;94;95;97;99;101;103;105;107;109;111;113;115;117;120;123;126;129;132;135;138;140;142;144;146;148;150;152;154;156;158;160;162;163;164;165;166;167;167;168;168;169;169;170;170;169;169;168;168;167;166;165;164;163;162;161;160;159;158;157;155;153;151;149;147;145;143;141;139;137;135;133;131;129;127;125;123;121;119;117;115;113;111;109;107;105;103;101;100;99;98;97;96;95;94;93;92;92;91;91;90;90;90;91;91;92;92;93;95;97;99;102;105;108;111;114;117;120;123;126;129;132;134;136;137;138;139;139;140;140;139;139;138;137;136;135;134;132;130;128;126;124;122;120;118;116;115;114;113;112;111;110;109;108;107;106;105;104;103;102;102;101;101;100;100;100;101;101;102;103;104;105;106;107;108;109;110;111;112;113;115;117;119;121;123;125;127;129;131;133;135;137;139;141;143;144;145;146;147;148;149;150;151;152;153;154;155;156;157;158;159;159;160;160;160;159;159;158;158;157;157;156;155;154;153;151;149;147;145;143;141;139;137;135;133;131;129;127;124;121;118;115;112;109;106;103;100;97;94;91;88;85;82;79;76;73;70;67;64;61;59;57;55;53;51;49;47;45;43;41;39;38;37;36;35;34;33;32;31;30;29;28;27;26;25;24;24;23;23;22;22;21;21;20;20;20;21;21;22;22;23;23;24;24;25;26;27;28;29;30;31;32;34;36;38;40;42;44;46;48;50;52;54;56;58;60;62;64;66;69;72;75;78;81;84;87;90;93;96;99;102;105;108;111;114;117;120;123;126;129;132;135;138;141;144;147;150;152;154;156;158;160;162;163;164;165;166;167;168;168;169;169;170;170;169;169;168;167;166;164;162;159;156;153;150;148;146;144;143;142;141;141;140;140;140;141;141;142;143;144;146;148;151;152;153;154;155;156;157;158;158;159;159;160;160;159;159;158;157;156;154;151;148;145;141;137;133;129;125;121;118;115;112;109;106;103;101;99;97;95;93;92;91;90;89;88;87;86;85;84;83;82;81;80;79;78;78;77;77;77;78;78;79;80;81;82;83;84;85;86;87;88;89;90;91;92;93;94;95;96;97;98;99;100;101;102;103;105;107;109;111;113;115;117;120;123;126;129;132;135;138;140;142;144;146;148;150;152;154;156;158;160;162;163;164;165;166;167;167;168;168;169;169;170;170;169;169;168;168;167;166;165;164;163;162;161;160;159;158;157;155;153;151;149;147;145;143;141;139;137;135;133;131;129;127;125;123;121;119;117;115;113;111;109;107;105;103;101;100;99;98;97;96;95;94;93;92;92;91;91;90;90;90;91;91;92;92;93;95;97;99;102;105;108;111;114;117;120;123;126;129;132;134;136;137;138;139;139;140;140;139;139;138;137;136;135;134;132;130;128;126;124;122;120;118;116;115;114;113;112;111;110;109;108;107;106;105;104;103;102;102;101;101;100;100;100;101;101;102;103;104;105;106;107;108;109;110;111;112;113;115;117;119;121;123;125;127;129;131;133;135;137;139;141;143;144;145;146;147;148;149;150;151;152;153;154;155;156;157;158;159;159;160;160;160;159;159;158;158;157;157;156;155;154;153;151;149;147;145;143;141;139;137;135;133;131;129;127;124;121;118;115;112;109;106;103;100;97;94;91;88;85;82;79;76;73;70;67;64;61;59;57;55;53;51;49;47;45;43;41;39;38;37;36;35;34;33;32;31;30;29;28;27;26;25;24;24;23;23;22;22;21;21;20;20;20;21;21;22;22;23;23;24;24;25;26;27;28;29;30;31;32;34;36;38;40;42;44;46;48;50;52;54;56;58;60;62;64;66;69;72;75;78;81;84;87;90;93;96;99;102;105;108;111;114;117;120;123;126;129;132;135;138;141;144;147;150;152;154;156;158;160;162;163;164;165;166;167;168;168;169;169;170;170;169;169;168;167;166;164;162;159;156;153;150;148;146;144;143;142;141;141;140;140;140;141;141;142;143;144;146;148;151;152;153;154;155;156;157;158;158;159;159;160;160;159;159;158;157;156;154;151;148;145;141;137;133;129;125;121;118;115;112;109;106;103;101;99;97;95;93;92;91;90;89;88;87;86;85;84;83;82;81;80;79;78;78;77;77;77;78;78;79;80;81;82;83;84;85;86;87;88;89;90;91;92;93;94;95;96;97;98;99;100;101;102;103;105;107;109;111;113;115;117;120;123;126;129;132;135;138;140;142;144;146;148;150;152;154;156;158;160;162;163;164;165;166;167;167;168;168;169;169;170;170;169;169;168;168;167;166;165;164;163;162;161;160;159;158;157;155;153;151;149;147;145;143;141;139;137;135;133;131;129;127;125;123;121;119;117;115;113;111;109;107;105;103;101;100;99;98;97;96;95;94;93;92;92;91;91;90;90;90;91;91;92;92;93;95;97;99;102;105;108;111;114;117;120;123;126;129;132;134;136;137;138;139;139;140;140;139;139;138;137;136;135;134;132;130;128;126;124;122;120;118;116;115;114;113;112;111;110;109;108;107;106;105;104;103;102;102;101;101;100;100;100;101;101;102;103;104;105;106;107;108;109;110;111;112;113;115;117;119;121;123;125;127;129;131;133;135;137;139;141;143;144;145;146;147;148;149;150;151;152;153;154;155;156;157;158;159;159;160;160;160;159;159;158;158;157;157;156;155;154;153;151;149;147;145;143;141;139;137;135;133;131;129;127;124;121;118;115;112;109;106;103;100;97;94;91;88;85;82;79;76;73;70;67;64;61;59;57;55;53;51;49;47;45;43;41;39;38;37;36;35;34;33;32;31;30;29;28;27;26;25;24;24;23;23;22;22;21;21;20;20;20;21;21;22;22;23;23;24;24;25;26;27;28;29;30;31;32;34;36;38;40;42;44;46;48;50;52;54;56;58;60;62;64;66;69;72;75;78;81;84;87;90;93;96;99;102;105;108;111;114;117;120;123;126;129;132;135;138;141;144;147;150;152;154;156;158;160;162;163;164;165;166;167;168;168;169;169;170;170;169;169;168;167;166;164;162;159;156;153;150;148;146;144;143;142;141;141;140;140;140;141;141;142;143;144;146;148;151;152;153;154;155;156;157;158;158;159;159;160;160;159;159;158;157;156;154;151;148;145;141;137;133;129;125;121;118;115;112;109;106;103;101;99;97;95;93;92;91;90;89;88;87;86;85;84;83;82;81;80;79;78;78;77;77;77;78;78;79;80;81;82;83;84;85;86;87;88;89;90];
SPFT_d0.SMP=[113;116;118;121;124;127;130;133;136;139;141;144;147;149;152;154;157;159;161;164;166;168;170;171;173;175;177;178;179;181;182;183;184;185;186;186;187;187;187;188;188;188;187;187;187;186;186;185;184;183;182;181;179;178;177;175;173;171;170;168;166;164;161;159;157;154;152;149;147;144;141;139;136;133;130;127;124;121;118;116;113;110;107;104;101;98;95;92;89;87;84;81;79;76;73;71;69;66;64;62;60;58;56;54;52;50;49;47;46;44;43;42;41;40;40;39;39;38;38;38;38;38;38;38;39;39;40;40;41;42;43;44;46;47;49;50;52;54;56;58;60;62;64;66;69;71;73;76;79;81;84;87;89;92;95;98;101;104;107;110;113;116;118;121;124;127;130;133;136;139;141;144;147;149;152;154;157;159;161;164;166;168;170;171;173;175;177;178;179;181;182;183;184;185;186;186;187;187;187;188;188;188;187;187;187;186;186;185;184;183;182;181;179;178;177;175;173;171;170;168;166;164;161;159;157;154;152;149;147;144;141;139;136;133;130;127;124;121;118;116;113;110;107;104;101;98;95;92;89;87;84;81;79;76;73;71;69;66;64;62;60;58;56;54;52;50;49;47;46;44;43;42;41;40;40;39;39;38;38;38;38;38;38;38;39;39;40;40;41;42;43;44;46;47;49;50;52;54;56;58;60;62;64;66;69;71;73;76;79;81;84;87;89;92;95;98;101;104;107;110;113;116;118;121;124;127;130;133;136;139;141;144;147;149;152;154;157;159;161;164;166;168;170;171;173;175;177;178;179;181;182;183;184;185;186;186;187;187;187;188;188;188;187;187;187;186;186;185;184;183;182;181;179;178;177;175;173;171;170;168;166;164;161;159;157;154;152;149;147;144;141;139;136;133;130;127;124;121;118;116;113;110;107;104;101;98;95;92;89;87;84;81;79;76;73;71;69;66;64;62;60;58;56;54;52;50;49;47;46;44;43;42;41;40;40;39;39;38;38;38;38;38;38;38;39;39;40;40;41;42;43;44;46;47;49;50;52;54;56;58;60;62;64;66;69;71;73;76;79;81;84;87;89;92;95;98;101;104;107;110;113;116;118;121;124;127;130;133;136;139;141;144;147;149;152;154;157;159;161;164;166;168;170;171;173;175;177;178;179;181;182;183;184;185;186;186;187;187;187;188;188;188;187;187;187;186;186;185;184;183;182;181;179;178;177;175;173;171;170;168;166;164;161;159;157;154;152;149;147;144;141;139;136;133;130;127;124;121;118;116;113;110;107;104;101;98;95;92;89;87;84;81;79;76;73;71;69;66;64;62;60;58;56;54;52;50;49;47;46;44;43;42;41;40;40;39;39;38;38;38;38;38;38;38;39;39;40;40;41;42;43;44;46;47;49;50;52;54;56;58;60;62;64;66;69;71;73;76;79;81;84;87;89;92;95;98;101;104;107;110;113;116;118;121;124;127;130;133;136;139;141;144;147;149;152;154;157;159;161;164;166;168;170;171;173;175;177;178;179;181;182;183;184;185;186;186;187;187;187;188;188;188;187;187;187;186;186;185;184;183;182;181;179;178;177;175;173;171;170;168;166;164;161;159;157;154;152;149;147;144;141;139;136;133;130;127;124;121;118;116;113;110;107;104;101;98;95;92;89;87;84;81;79;76;73;71;69;66;64;62;60;58;56;54;52;50;49;47;46;44;43;42;41;40;40;39;39;38;38;38;38;38;38;38;39;39;40;40;41;42;43;44;46;47;49;50;52;54;56;58;60;62;64;66;69;71;73;76;79;81;84;87;89;92;95;98;101;104;107;110;113;116;118;121;124;127;130;133;136;139;141;144;147;149;152;154;157;159;161;164;166;168;170;171;173;175;177;178;179;181;182;183;184;185;186;186;187;187;187;188;188;188;187;187;187;186;186;185;184;183;182;181;179;178;177;175;173;171;170;168;166;164;161;159;157;154;152;149;147;144;141;139;136;133;130;127;124;121;118;116;113;110;107;104;101;98;95;92;89;87;84;81;79;76;73;71;69;66;64;62;60;58;56;54;52;50;49;47;46;44;43;42;41;40;40;39;39;38;38;38;38;38;38;38;39;39;40;40;41;42;43;44;46;47;49;50;52;54;56;58;60;62;64;66;69;71;73;76;79;81;84;87;89;92;95;98;101;104;107;110;113;116;118;121;124;127;130;133;136;139;141;144;147;149;152;154;157;159;161;164;166;168;170;171;173;175;177;178;179;181;182;183;184;185;186;186;187;187;187;188;188;188;187;187;187;186;186;185;184;183;182;181;179;178;177;175;173;171;170;168;166;164;161;159;157;154;152;149;147;144;141;139;136;133;130;127;124;121;118;116;113;110;107;104;101;98;95;92;89;87;84;81;79;76;73;71;69;66;64;62;60;58;56;54;52;50;49;47;46;44;43;42;41;40;40;39;39;38;38;38;38;38;38;38;39;39;40;40;41;42;43;44;46;47;49;50;52;54;56;58;60;62;64;66;69;71;73;76;79;81;84;87;89;92;95;98;101;104;107;110;113;116;118;121;124;127;130;133;136;139;141;144;147;149;152;154;157;159;161;164;166;168;170;171;173;175;177;178;179;181;182;183;184;185;186;186;187;187;187;188;188;188;187;187;187;186;186;185;184;183;182;181;179;178;177;175;173;171;170;168;166;164;161;159;157;154;152;149;147;144;141;139;136;133;130;127;124;121;118;116;113;110;107;104;101;98;95;92;89;87;84;81;79;76;73;71;69;66;64;62;60;58;56;54;52;50;49;47;46;44;43;42;41;40;40;39;39;38;38;38;38;38;38;38;39;39;40;40;41;42;43;44;46;47;49;50;52;54;56;58;60;62;64;66;69;71;73;76;79;81;84;87;89;92;95;98;101;104;107;110;113;116;118;121;124;127;130;133;136;139;141;144;147;149;152;154;157;159;161;164;166;168;170;171;173;175;177;178;179;181;182;183;184;185;186;186;187;187;187;188;188;188;187;187;187;186;186;185;184;183;182;181;179;178;177;175;173;171;170;168;166;164;161;159;157;154;152;149;147;144;141;139;136;133;130;127;124;121;118;116;113;110;107;104;101;98;95;92;89;87;84;81;79;76;73;71;69;66;64;62;60;58;56;54;52;50;49;47;46;44;43;42;41;40;40;39;39;38;38;38;38;38;38;38;39;39;40;40;41;42;43;44;46;47;49;50;52;54;56;58;60;62;64;66;69;71;73;76;79;81;84;87;89;92;95;98;101;104;107;110];
SPFT_d0.resampleFactor = 10; % "= 1/10th the number of samples" factor for resampling data for vel acc and jrk calculations (required because the signal is smoothly varying)
SPFT_d0.fileNameTail='-SPFT_7T_localize_newForce.log';
clear temp;


% all_files=dir(strcat(dataDir,'/*','d*','-SPFT_7T_Daily*log'));
% all_files
% %construct the IDs variable (1st 7 chars of the filename to include the d? designation)
% for count=1:length(all_files)
%     IDs{count}=all_files(count).name(1:7);
%     % remove the NA values from the files so that you can process them
% end
% SPFT_d0.IDs=IDs;

subjectDirs={'KP8T','OL1T','GAIT','LM8T','BI3T','WSFT','KSYT','MART','HCBT','JMCT','KPFT','HR8T','NMFT','FA2T','SCZT','PMIT','SJ6X','BP4T'}; %XXX THIS WILL CHANGE TO PID ONLY, will be able to get rid of it then! :-)
IDs={'P02','P03','P04','P05','P06','P07','P08','P09','P10','P11','P12','P13','P14','P15','P16','P17','P18','P20'};

SPFT_d0.IDs=IDs;
SPFT_d0.subjectDirs=subjectDirs;
SPFT_d0.numDays=1

%loop over subjects
for ID=1:length(IDs)
    fprintf('--- Processing %s ---\n',IDs{ID});
    temp.headerFormat=repmat('%s',1,16);
    temp.logFormat='%s\t%f %s %s %f\t%f\t%f %f %f %f %s %s %f'; %last 4 are to make sure it doesn't crash on non-std lines
    
    %loop over days
    for day=1:SPFT_d0.numDays
        % localiser is d0, so refer to it as day-1
        temp.fname=strcat(SPFT_d0.dataDir,subjectDirs{ID},'/bx/',IDs{ID},'_d',num2str(day-1),SPFT_d0.fileNameTail); %figure out what the trial name should be
        fprintf('%s\n',temp.fname);
        temp.day=day;
        if exist(temp.fname,'file')==2
            temp.fid=fopen(temp.fname);
            temp.val=textscan(temp.fid,'%s%s%s',3); %get the crap in the top of the file out of the way
            temp.myLogHeader=textscan(temp.fid,temp.headerFormat,1);
            %temp.val=textscan(temp.fid,'%s',1); %skip one more line
            temp.myLog=textscan(temp.fid,temp.logFormat); %the position data is in 6 with the global time in 7 and reset-time in 8
            % XXX IMPORTANT - not all data in 6 is position data (or time in 7 or 8)
            % because of the way that the data was stored
            fclose(temp.fid);
            
            
            %get locations for each block of trials and each trial
            temp.dataType=temp.myLog{4}; %holds a cell array with all of the data types for the corresponding data (Input=force device input, Trial_*= for trial starts...)
            temp.data=cell2mat(temp.myLog(6:9));
            
            %%%collect and remove the fMRI triggers
            temp.idx=strfind(temp.dataType,'99'); %collect the fMRI triggers first, they need to be scrubbed from the rest of the data because the values are IN THE WRONG FUCKING COLUMNS!
            temp.fMRItrig=not(cellfun(@isempty,temp.idx));
            temp.tt=cell2mat(temp.myLog(5)); %need another var because we need one extra column of data...
            temp.fMRIonset=temp.tt(temp.fMRItrig); %collect the trigger onset time
            clear temp.tt;
            temp.data(temp.fMRItrig,:)=[]; %scrub it from the real data, it screws things up
            temp.dataType(temp.fMRItrig,:)=[]; %scrub it from the index too!
            %%%
            
            %%%determine the force/weight setting of the device
            temp.idx=strfind(temp.dataType,'set_range_');
            temp.setWeight=not(cellfun(@isempty,temp.idx));
            temp.setWeight=temp.dataType(temp.setWeight==1); %recode so that we have the text that tells us which weights were set
            
            %%%determine the max force of this individual (kg, 8bit, old value)
            temp.idx=strfind(temp.dataType,'Maxwert_Kg');
            temp.setMaxVal_Kg=not(cellfun(@isempty,temp.idx));
            temp.scrubMe=temp.setMaxVal_Kg;
            temp.setMaxVal_Kg=temp.dataType(temp.setMaxVal_Kg==1); %recode
            temp.maxVal_Kg = str2num(cell2mat(strtok(temp.setMaxVal_Kg,'Maxwert_Kg_'))); % convert this text to a number that we can use in calcs
            temp.data(temp.scrubMe,:)=[]; %scrub it from the real data, it screws things up
            temp.dataType(temp.scrubMe,:)=[]; %scrub it from the index too!
            
            
            temp.idx=strfind(temp.dataType,'Maxwert_8bit');
            temp.setMaxVal_8bit=not(cellfun(@isempty,temp.idx));
            temp.scrubMe=temp.setMaxVal_8bit;
            temp.setMaxVal_8bit=temp.dataType(temp.setMaxVal_8bit==1); %recode
            temp.maxVal_8bit = str2num(cell2mat(strtok(temp.setMaxVal_8bit,'Maxwert_8bit'))); % convert this text to a number that we can use in calcs
            temp.data(temp.scrubMe,:)=[]; %scrub it from the real data, it screws things up
            temp.dataType(temp.scrubMe,:)=[]; %scrub it from the index too!
            
            temp.idx=strfind(temp.dataType,'Maxwert_');
            temp.setMaxVal=not(cellfun(@isempty,temp.idx));
            temp.setMaxVal=temp.dataType(temp.setMaxVal==1); %recode
            temp.maxVal = str2num(cell2mat(strtok(temp.setMaxVal,'Maxwert_'))); % convert this text to a number that we can use in calcs
            temp.shiftFactor = 16; %shift_faktor from Sven's code
            
            temp.remappedMaxVal = (temp.maxVal*240*20/850+2)/16; %remaps the max val reported in the log file to 0-255 output from device -> this is the use to calculate actual weight/force exerted
            
            if length(temp.setWeight) == 2 %there should be TWO setting because we have not yet SPECIFIED the range -only use the 2nd one because the first just sets the max on the device at the start (previously, 2 were recorded because we set to default (15kg) and then reset when Maximalkraft was done)
                if strcmp(temp.setWeight{2},'set_range_938g')
                    temp.sensorMaxWeight=.9375;
                    temp.rangeFactor=1;
                elseif (strcmp(temp.setWeight{2},'set_range_1p875kg') || strcmp(temp.setWeight{2},'set_range_1875g'))
                    temp.sensorMaxWeight=1.875;
                    temp.rangeFactor=2;
                elseif strcmp(temp.setWeight{2},'set_range_3p75kg')
                    temp.sensorMaxWeight=3.75;
                    temp.rangeFactor=4;
                elseif strcmp(temp.setWeight{2},'set_range_7p5kg')
                    temp.sensorMaxWeight=7.5;
                    temp.rangeFactor=8;
                elseif strcmp(temp.setWeight{2},'set_range_15kg')
                    temp.sensorMaxWeight=15;
                    temp.rangeFactor=16;
                else
                    temp.sensorMaxWeight=NaN;
                    warning('The set_range command is not what was expected. Something is wrong.');
                    break;
                end
                
                %%%conversion factor to transform sensor-reported values to values
                %%%of the bar on the screen and then what to multiply that by to
                %%%calculate the actual kg exerted
                %%% maximalkraft is always based on the 15kg sensor, so we need to
                %%% create the conversion factor based on this.
                temp.maxWeight=15*(((850*((255*temp.shiftFactor)-2))/(240*20))/temp.maxVal)^-1; % 15*(((850*((255*16)-2))/(240*20))/temp.maxVal)^-1 = actual force produced during maximalkraft
                temp.bar2weight=(temp.maxWeight*.3)/190;
                fprintf('Weight produced during maximalkraft: %.3f\nDevice pinch force sensor maximum weight (set): %.3f kg\nEach unit of bar height corresponds to %.3f kg\n',temp.maxWeight,temp.sensorMaxWeight,temp.bar2weight);
                %%%
                
                %%% YOU ARE HERE XXX
                temp.factorVar = temp.maxVal*.3/170*temp.shiftFactor/temp.rangeFactor;
                fprintf('maxwert = %i \t factor_val = %.2f\n',temp.maxVal,temp.factorVar);
                fprintf('max_old = %i \t max_8bit = %i \t max_Kg = %.2f\n',temp.maxVal,temp.maxVal_8bit,temp.maxVal_Kg);
                %this is the necessary calculation for the conversion factor, it mostly
                %follows Bettina's code and appears to work (the 190 is actually 170 in
                %her code and is not directly related to the range of the display, but
                %is just a factor that was used to calculate range earlier)
                % then, we multiply it by 16/rangeFactor to scale it according to
                % Sven's code
                %%%
                
            else
                warning('There are too many set_range commands in this file. Something is wrong.');
                break;
            end
            
            %%%
            
            temp.idx=strfind(temp.dataType,'Trial_Start');
            temp.trialOn=not(cellfun(@isempty,temp.idx));
            temp.trialOn=find(temp.trialOn==1)+1; %now numerical index of first row after row with "Trial" in it
            temp.idx=strfind(temp.dataType,'SMP_instructions');
            temp.SMPidx=not(cellfun(@isempty,temp.idx));
            temp.SMPidx=find(temp.SMPidx==1)+1;
            temp.idx=strfind(temp.dataType,'LRN_instructions');
            temp.LRNidx=not(cellfun(@isempty,temp.idx));
            temp.LRNidx=find(temp.LRNidx==1)+1;
            temp.idx=strfind(temp.dataType,'RST_instructions');
            temp.RSTidx=not(cellfun(@isempty,temp.idx));
            temp.RSTidx=find(temp.RSTidx==1)+1;
            fprintf('Trial and Instruction start times retrieved\n');
            
            
            
            %retrieve the times to reconstruct the fMRI design
            %block onsets, in seconds XXX
            temp.GLM.SMPblocks=(temp.data(temp.SMPidx,2)-temp.fMRIonset(1))/10000;
            temp.GLM.LRNblocks=(temp.data(temp.LRNidx,2)-temp.fMRIonset(1))/10000;
            temp.GLM.RSTblocks=(temp.data(temp.RSTidx,2)-temp.fMRIonset(1))/10000;
            
            %add block duration and code
            temp.GLM.SMPblocks=[temp.GLM.SMPblocks ones(length(temp.GLM.SMPblocks),1)*SPFT_d0.blockDuration ones(length(temp.GLM.SMPblocks),1)];
            temp.GLM.LRNblocks=[temp.GLM.LRNblocks ones(length(temp.GLM.LRNblocks),1)*SPFT_d0.blockDuration ones(length(temp.GLM.LRNblocks),1)];
            
            %trial onsets
            temp.GLM.trialOn=(temp.data(temp.trialOn,2)-temp.fMRIonset(1))/10000;
            
            temp.xxtimings=[temp.GLM.SMPblocks(:,1) ones(size(temp.GLM.SMPblocks,1),1);temp.GLM.LRNblocks(:,1) ones(size(temp.GLM.LRNblocks,1),1)*2;temp.GLM.RSTblocks(:,1) ones(size(temp.GLM.RSTblocks,1),1)*3];
            %temp.xxtimings=sort(temp.xxtimings,1)
            
            fprintf('Created GLM design for this participant and day.\n');
            if SHOWPLOTS
                figure('name','GLM design');
                plot(temp.GLM.SMPblocks, zeros(length(temp.GLM.SMPblocks),1)+.1,'g+','markersize',8);
                hold on;
                plot(temp.GLM.LRNblocks, zeros(length(temp.GLM.LRNblocks),1)+.1,'b+','markersize',8);
                plot(temp.GLM.RSTblocks, zeros(length(temp.GLM.RSTblocks),1)+.1,'k+','markersize',8);
                plot(temp.GLM.trialOn, zeros(length(temp.GLM.trialOn),1),'r.','markersize',8);
                ylim([-.25,.25]);
                legend({'SMP' 'RST' 'TrialOn'});
            end
            %cut the data into trials
            temp.out.trial.rawForce=cell(SPFT_d0.totalTrials,1);
            temp.out.trial.rawTime=temp.out.trial.rawForce;
            temp.out.trial.remappedSensorVal=temp.out.trial.rawForce;
            temp.out.trial.remappedForce=temp.out.trial.rawForce;
            % f1=figure;
            for trial=1:length(temp.trialOn)
                temp.trialOnTime=temp.data(temp.trialOn(trial),2); %time for first response AFTER the Trial_Start was logged
                temp.trialOffTime=temp.trialOnTime+SPFT_d0.seqDur*10000; %
                temp.trialOffIdx=find(temp.data(temp.trialOn(trial):end,2) >= temp.trialOffTime,1,'first')+temp.trialOn(trial)-1; %this is the index within temp.data of the trialOff for this trial
                
                temp.out.trial.rawForce{trial,1}=temp.data(temp.trialOn(trial):temp.trialOffIdx,1);
                temp.out.trial.rawTime{trial,1}=temp.data(temp.trialOn(trial):temp.trialOffIdx,2); %time in microseconds (needs to be zero'd)
                temp.out.trial.remappedSensorVal{trial,1}=((temp.out.trial.rawForce{trial,1}.*temp.shiftFactor)-2)*850/240/20/temp.factorVar; %%% this is where the magical transform changes the sensor_var to the bar-related value
                temp.out.trial.remappedForce{trial,1}=temp.out.trial.remappedSensorVal{trial,1}*temp.bar2weight; % this appears to be correct, but should probably check with some kind of weight...
                
                %         plot(temp.out.trial.rawTime{trial},temp.out.trial.rawForce{trial},'bo-');hold on;
                %         plot(temp.out.trial.rawTime{trial},temp.out.trial.remappedSensorVal{trial},'ro-');
                %
                %        % plot(SPFT_d0.SMP,'go-');
                %          set(f1,'name',num2str(trial));
                %pause;
            end
            
            % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            % START create a summary force measure per volume
            % temp.out.rawForce_per_TR
            % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            temp.fMRI_vol_start=temp.fMRIonset(1:1:end);%XXX don't DIVIDE BY 2 BECAUSE not using VASO here!
            temp.fMRI_vol_stop =temp.fMRI_vol_start+(SPFT_d0.TR*10000);
            temp.out.rawForce_per_TR=zeros(length(temp.fMRI_vol_start),1)*NaN; 
            
            
            for vol=1:length(temp.fMRI_vol_start)
                temp.firstSample=find(temp.data(:,2)>temp.fMRI_vol_start(vol),1,'first'); %look for first occurence of data after the fMRI trigger
                temp.lastSample=find(temp.data(:,2)>temp.fMRI_vol_stop(vol),1,'first')-1-1; %look for first occurence of data when the time elapsed, remove one sample to make sure there is no overlap
                if vol == length(temp.fMRI_vol_start)
                    temp.lastSample=length(temp.data(:,2)); %use the last sample that was collected
                end
                temp.argh=temp.data(temp.firstSample:temp.lastSample,1);
                temp.argh(temp.argh>256)=[]; %remove any values that are not actually due to the sensor, which only reports values up to 128 or so.
                temp.out.rawForce_per_TR(vol)=nanmean(temp.argh); %put one lower, we filled the first vol manually
                %temp.out.rawForce_per_TR(vol)=mean(temp.data(temp.firstSample:temp.lastSample,1));
            end
            % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            % END create a summary force measure per volume
            % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            
            %partition out the data for the different trial types
            temp.out.measures={'RemappedSensorValue', 'RawTime', 'ForceValue', 'RawSensorValue'}; % where RemappedSensorValue contains the sensor_var converted into the bar level that was displayed
            %temp.out.measures={'RemappedSensorValue', 'RawTime', 'RawSensorValue'}; % where RemappedSensorValue contains the sensor_var converted into the bar level that was displayed
            temp.out.SMP=[temp.out.trial.remappedSensorVal(SPFT_d0.trialTypes==1) temp.out.trial.rawTime(SPFT_d0.trialTypes==1) temp.out.trial.remappedForce(SPFT_d0.trialTypes==1) temp.out.trial.rawForce(SPFT_d0.trialTypes==1)]; %FORCE and then Time
            temp.out.RST=[temp.out.trial.remappedSensorVal(SPFT_d0.trialTypes==2) temp.out.trial.rawTime(SPFT_d0.trialTypes==2) temp.out.trial.remappedForce(SPFT_d0.trialTypes==2) temp.out.trial.rawForce(SPFT_d0.trialTypes==2)];
            temp.out.LRN=[temp.out.trial.remappedSensorVal(SPFT_d0.trialTypes==3) temp.out.trial.rawTime(SPFT_d0.trialTypes==3) temp.out.trial.remappedForce(SPFT_d0.trialTypes==3) temp.out.trial.rawForce(SPFT_d0.trialTypes==3)];
            
            %remove some temp fields to clean it up
            temp=rmfield(temp,'val');
            temp=rmfield(temp,'idx');
            temp=rmfield(temp,'trialOnTime');
            temp=rmfield(temp,'trialOffTime');
            temp=rmfield(temp,'trialOffIdx');
            temp=rmfield(temp,'fid');
            
            SPFT_d0.fullData{ID,day}=temp; %create a new data structure to hold the full data for each individual from their log files
            fprintf('----------------------------------------------------\n\n');
            
            %clear temp;
        else
            warning('I could not find the files to load and process this day. Fix me. Now.')
            warning('No seriously, you are pissing me off.');
        end
        %assign this day of data to the data structure
        cmd=['SPFT_d0.' IDs{ID} '.d' num2str(day-1) '=temp;'];
        eval(cmd)
    end %close the loop on days
end
fprintf('--- Loading and parsing into trials is DONE DONE DONE DONE DONE DONE! - Be happy. ---\n');

%clear temp;
%file is over 800mb!

%% write out the stimulus design files for fMRI processing
% only d1 to start
outDir='/tmp/XXX_BOLD_d0_loc/';
for ID=1:length(IDs)
    for day=0:0%6
        IDtxt=IDs{ID};
        cmd=['theVar=SPFT_d0.',SPFT_d0.IDs{ID},'.d0.out.rawForce_per_TR;'];
        eval(cmd);
        dlmwrite(strcat(outDir,IDtxt,'_d',num2str(day),'_rawForce_per_TR.txt'),theVar);
        
        cmd=['theVar=SPFT_d0.',SPFT_d0.IDs{ID},'.d0.GLM.LRNblocks;'];
        eval(cmd);
        dlmwrite(strcat(outDir,IDtxt,'_d',num2str(day),'_LRNblocks.txt'),theVar);

        cmd=['theVar=SPFT_d0.',SPFT_d0.IDs{ID},'.d0.GLM.SMPblocks;'];
        eval(cmd);
        dlmwrite(strcat(outDir,IDtxt,'_d',num2str(day),'_SMPblocks.txt'),theVar);
        
    end
end

%% 


% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% PROCESS / SCORE the data for all IDs/Days
% creates SPFT_d0.all structure with all scored
% trial average data arranged by ID,day
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

% now calculate some useful values from the collected raw data
% XXX CHANGE THIS TO CALCULATE BASED ON EACH DAY OF DATA XXX
clear temp;
temp.temp=[];
temp.out.all.rmseLRN=cell(length(SPFT_d0.IDs),SPFT_d0.numDays);
temp.out.all.rmseSMP=temp.out.all.rmseLRN;
temp.out.all.alignedrmseLRN=temp.out.all.rmseLRN;
temp.out.all.alignedrmseSMP=temp.out.all.rmseLRN;
temp.out.all.rtLRN=temp.out.all.rmseLRN;
temp.out.all.rtSMP=temp.out.all.rmseLRN;
temp.out.all.normrLRN=temp.out.all.rmseLRN;
temp.out.all.normrSMP=temp.out.all.rmseLRN;
% temp.out.all.varLRN=temp.out.all.rmseLRN;
% temp.out.all.varSMP=temp.out.all.rmseLRN;
temp.out.all.respLRN=temp.out.all.rmseLRN;
temp.out.all.respSMP=temp.out.all.rmseLRN;
temp.out.all.errorlagcorrLRN=temp.out.all.rmseLRN; %lag between error and force
temp.out.all.errorlagcorrSMP=temp.out.all.rmseLRN;
temp.out.all.lagLRN=temp.out.all.rmseLRN;
temp.out.all.lagSMP=temp.out.all.rmseLRN;
temp.out.all.velLRN=temp.out.all.rmseLRN;
temp.out.all.accLRN=temp.out.all.rmseLRN;
temp.out.all.jrkLRN=temp.out.all.rmseLRN;
temp.out.all.velSMP=temp.out.all.rmseLRN;
temp.out.all.accSMP=temp.out.all.rmseLRN;
temp.out.all.jrkSMP=temp.out.all.rmseLRN;

for ID=1:length(IDs)
    fprintf('--- Processing/Scoring %s ---\n',IDs{ID});
    temp.out.rmseLRN=repmat(NaN,1,SPFT_d0.numBlocks*SPFT_d0.numTrials);
    temp.out.rmseSMP=repmat(NaN,1,SPFT_d0.numBlocks*SPFT_d0.numTrials);
    temp.out.alignedrmseLRN=temp.out.rmseLRN;
    temp.out.alignedrmseSMP=temp.out.rmseLRN;
    temp.out.respLRN=temp.out.rmseSMP;
    temp.out.respSMP=temp.out.rmseSMP;
    temp.out.errorlagcorrLRN=temp.out.rmseSMP;
    temp.out.errorlagcorrSMP=temp.out.rmseSMP;
    temp.out.lagLRN=temp.out.rmseSMP;
    temp.out.lagSMP=temp.out.rmseSMP;
    temp.out.normrLRN=temp.out.rmseSMP;
    temp.out.normrSMP=temp.out.rmseSMP;
    temp.out.velaccjrkLRN=repmat(NaN,3,SPFT_d0.numBlocks*SPFT_d0.numTrials);
    temp.out.velaccjrkSMP=repmat(NaN,3,SPFT_d0.numBlocks*SPFT_d0.numTrials);
    
    %loop over days
    for day=1:SPFT_d0.numDays
        fprintf('Day %i\t Trial ',day);
        
        
        for trial=1:SPFT_d0.numBlocks*SPFT_d0.numTrials
            fprintf('%i ',trial);
            
            try
                %downsample the data to the same temporal resolution as the
                %data that we are trying to match, then calculate our measures
                %of interest
                temp.LRNresp=resample(SPFT_d0.fullData{ID,day}.out.LRN{trial,1},SPFT_d0.seqLength,length(SPFT_d0.fullData{ID,day}.out.LRN{trial,1}));
                temp.SMPresp=resample(SPFT_d0.fullData{ID,day}.out.SMP{trial,1},SPFT_d0.seqLength,length(SPFT_d0.fullData{ID,day}.out.SMP{trial,1}));
                %[temp.temp temp.out.errorlagLRN(trial)]=SPFT_calcTemporalOffset(abs(temp.LRNresp-SPFT_d0.LRN),temp.LRNresp); %xcorr relating the absolute error to the force that is used
                %[temp.temp temp.out.errorlagSMP(trial)]=SPFT_calcTemporalOffset(abs(temp.SMPresp-SPFT_d0.SMP),temp.SMPresp);
                [r p]=corrcoef(abs(temp.LRNresp-SPFT_d0.LRN),temp.LRNresp); %xcorr relating the absolute error to the force that is used
                if p(1,2)>.05
                    r(1,2)=NaN;
                end
                temp.out.errorlagcorrLRN(trial)=r(1,2);
                [r p]=corrcoef(abs(temp.SMPresp-SPFT_d0.SMP),temp.SMPresp);
                if p(1,2)>.05
                    r(1,2)=NaN;
                end
                temp.out.errorlagcorrSMP(trial)=r(1,2);
                
                
                temp.out.respLRN(trial)=mean(temp.LRNresp);
                temp.out.respSMP(trial)=mean(temp.SMPresp);
                temp.out.rmseLRN(trial)=sqrt(sum((temp.LRNresp-SPFT_d0.LRN).^2)./SPFT_d0.seqLength);%/mean(temp.LRNresp);%/range(temp.LRNresp); %different ways of normalising RMSE
                temp.out.rmseSMP(trial)=sqrt(sum((temp.SMPresp-SPFT_d0.SMP).^2)./SPFT_d0.seqLength);%/mean(temp.SMPresp);
                
                [temp.out.normrLRN(trial) temp.out.lagLRN(trial)]=SPFT_calcTemporalOffset(SPFT_d0.LRN,temp.LRNresp);
                [temp.out.normrSMP(trial) temp.out.lagSMP(trial)]=SPFT_calcTemporalOffset(SPFT_d0.SMP,temp.SMPresp);
                
                temp.shiftedLRNdiff=circshift(temp.LRNresp,temp.out.lagLRN(trial))-SPFT_d0.LRN;
                temp.shiftedSMPdiff=circshift(temp.SMPresp,temp.out.lagSMP(trial))-SPFT_d0.SMP;
                if temp.out.lagLRN(trial)>0
                    temp.shiftedLRNdiff=temp.shiftedLRNdiff(temp.out.lagLRN(trial)+1:end);
                else
                    temp.shiftedLRNdiff=temp.shiftedLRNdiff(1:length(temp.shiftedLRNdiff)+temp.out.lagLRN(trial));
                end
                
                if temp.out.lagSMP(trial)>0
                    temp.shiftedSMPdiff=temp.shiftedSMPdiff(temp.out.lagSMP(trial)+1:end);
                else
                    temp.shiftedSMPdiff=temp.shiftedSMPdiff(1:length(temp.shiftedSMPdiff)+temp.out.lagSMP(trial));
                end
                
                temp.out.alignedrmseLRN(trial)=sqrt(sum((temp.shiftedLRNdiff).^2)./length(temp.shiftedLRNdiff));
                temp.out.alignedrmseSMP(trial)=sqrt(sum((temp.shiftedSMPdiff).^2)./length(temp.shiftedSMPdiff));
                
                [temp.out.velaccjrkLRN(1,trial) temp.out.velaccjrkLRN(2,trial) temp.out.velaccjrkLRN(3,trial)]=SPFT_calcVelAccJrk(temp.LRNresp,SPFT_d0.resampleFactor);
                [temp.out.velaccjrkSMP(1,trial) temp.out.velaccjrkSMP(2,trial) temp.out.velaccjrkSMP(3,trial)]=SPFT_calcVelAccJrk(temp.SMPresp,SPFT_d0.resampleFactor);
                
                %             [Dist,D,k,w]=dtw(SPFT_d0.LRN(:)',temp.LRNresp(:)'); %dynamic time warping calculation
                %             temp.out.kLRN(trial)=k;
                %             [Dist,D,k,w]=dtw(SPFT_d0.SMP(:)',temp.SMPresp(:)');
                %             temp.out.kSMP(trial)=k;
            catch
                warning('%s trial %i was not scored properly\n',SPFT_d0.IDs{ID},trial);
            end
            
        end %end trial loop
        fprintf('\n');
        
        
        %     figure('name',IDs{ID});
        %     plot(temp.out.rmseLRN,'bo-')
        %     hold on;
        %   plot(temp.out.rmseSMP,'go-')
        
        temp.out.all.rmseLRN{ID,day}=[temp.out.all.rmseLRN{ID,day}; temp.out.rmseLRN];
        temp.out.all.rmseSMP{ID,day}=[temp.out.all.rmseSMP{ID,day}; temp.out.rmseSMP];
        temp.out.all.alignedrmseLRN{ID,day}=[temp.out.all.alignedrmseLRN{ID,day}; temp.out.alignedrmseLRN];
        temp.out.all.alignedrmseSMP{ID,day}=[temp.out.all.alignedrmseSMP{ID,day}; temp.out.alignedrmseSMP];
        temp.out.all.respLRN{ID,day}=[temp.out.all.respLRN{ID,day}; temp.out.respLRN];
        temp.out.all.respSMP{ID,day}=[temp.out.all.respSMP{ID,day}; temp.out.respSMP];
        %temp.out.all.rtLRN=[temp.out.all.rtLRN; temp.out.rtLRN];
        %temp.out.all.rtSMP=[temp.out.all.rtSMP; temp.out.rtSMP];
        temp.out.all.normrLRN{ID,day}=[temp.out.all.normrLRN{ID,day}; temp.out.normrLRN];
        temp.out.all.normrSMP{ID,day}=[temp.out.all.normrSMP{ID,day}; temp.out.normrSMP];
        %     temp.out.all.varLRN=[temp.out.all.varLRN; temp.out.varLRN];
        %     temp.out.all.varSMP=[temp.out.all.varSMP; temp.out.varSMP];
        %temp.out.all.errorlagLRN=[temp.out.all.errorlagLRN; 90/80*temp.out.errorlagLRN/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1];%*1/60*-1000];%/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1]; %lag (ms) from reference onset
        %temp.out.all.errorlagSMP=[temp.out.all.errorlagSMP; 90/80*temp.out.errorlagSMP/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1];%*1/60*-1000];%/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1];
        temp.out.all.errorlagcorrLRN{ID,day}=[temp.out.all.errorlagcorrLRN{ID,day}; temp.out.errorlagcorrLRN];%*1/60*-1000];%/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1]; %lag (ms) from reference onset
        temp.out.all.errorlagcorrSMP{ID,day}=[temp.out.all.errorlagcorrSMP{ID,day}; temp.out.errorlagcorrSMP];%*1/60*-1000];%/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1];
        
        temp.out.all.lagLRN{ID,day}=[temp.out.all.lagLRN{ID,day}; 90/80*temp.out.lagLRN/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1];%*1/60*-1000];%/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1]; %lag (ms) from reference onset
        temp.out.all.lagSMP{ID,day}=[temp.out.all.lagSMP{ID,day}; 90/80*temp.out.lagSMP/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1];%*1/60*-1000];%/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1];
        temp.out.all.velLRN{ID,day}=[temp.out.all.velLRN{ID,day}; temp.out.velaccjrkLRN(1,:)];
        temp.out.all.accLRN{ID,day}=[temp.out.all.accLRN{ID,day}; temp.out.velaccjrkLRN(2,:)];
        temp.out.all.jrkLRN{ID,day}=[temp.out.all.jrkLRN{ID,day}; temp.out.velaccjrkLRN(3,:)];
        temp.out.all.velSMP{ID,day}=[temp.out.all.velSMP{ID,day}; temp.out.velaccjrkSMP(1,:)];
        temp.out.all.accSMP{ID,day}=[temp.out.all.accSMP{ID,day}; temp.out.velaccjrkSMP(2,:)];
        temp.out.all.jrkSMP{ID,day}=[temp.out.all.jrkSMP{ID,day}; temp.out.velaccjrkSMP(3,:)];
    end %end day loop
end %end Ss loop

temp.out.all.measures={'ID','day'};
SPFT_d0.scoredData=temp.out.all;
clearvars -except SPFT

%save([SPFT_d0.dataDir filesep '2015_04_SPFT_7T_M1_forceCalibration_preProcessedData'],'SPFT','-v7.3')

%% plot individual subject data for specific measures
% specify the individual (by ID) and day(s)  (by vector)
ID=1;
days=1:5; %vector of days that I want to plot data for
SCALEX=true; %scale xlimits according to input data

theDataLRN=cell2mat(SPFT_d0.scoredData.alignedrmseLRN(ID,days)); %row=ID, column=trials across all days (i.e., 54)
theDataSMP=cell2mat(SPFT_d0.scoredData.alignedrmseSMP(ID,days));
plotName='RMSE';
yAxisName='Error (scaled absolute deviation)';
SPFT_plotIndividualData(theDataLRN,theDataSMP,plotName,yAxisName,SCALEX);

theDataLRN=cell2mat(SPFT_d0.scoredData.lagLRN(ID,days)); %row=ID, column=trials across all days (i.e., 54)
theDataSMP=cell2mat(SPFT_d0.scoredData.lagSMP(ID,days));
plotName='Max Lag Autocorrelation';
yAxisName='Lag (ms)';
SPFT_plotIndividualData(theDataLRN,theDataSMP,plotName,yAxisName,SCALEX);


%% now plot some group summary measures across days (number of trials per day has been hardcoded here because I am lazy) 
% requires more than one subject, but it works :)

f=figure('name','RMSE');
theDataLRN=cell2mat(SPFT_d0.scoredData.rmseLRN); %row=ID, column=trials across all days (i.e., 54)
theDataSMP=cell2mat(SPFT_d0.scoredData.rmseSMP); 
errorbar(nanmean(theDataLRN),nanstd(theDataLRN)./sqrt(length(IDs)),'bo-','linewidth',2);
hold on;
errorbar(nanmean(theDataSMP),nanstd(theDataSMP)./sqrt(length(IDs)),'go-','linewidth',2);

plot([9.5 9.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([18.5 18.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([27.5 27.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([36.5 36.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([45.5 45.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([54.5 54.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
xlabel('Trial');
ylabel('Error (scaled absolute deviation)');


figure('name','Lag-aligned RMSE');
theDataLRN=cell2mat(SPFT_d0.scoredData.alignedrmseLRN); %row=ID, column=trials across all days (i.e., 54)
theDataSMP=cell2mat(SPFT_d0.scoredData.alignedrmseSMP); 
errorbar(nanmean(theDataLRN),nanstd(theDataLRN)./sqrt(length(IDs)),'bo-','linewidth',2);
hold on;
errorbar(nanmean(theDataSMP),nanstd(theDataSMP)./sqrt(length(IDs)),'go-','linewidth',2);

plot([9.5 9.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([18.5 18.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([27.5 27.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([36.5 36.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([45.5 45.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([54.5 54.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
xlabel('Trial');
ylabel('Error (scaled absolute deviation)');

figure('name','Force Response');
theDataLRN=cell2mat(SPFT_d0.scoredData.respLRN); %row=ID, column=trials across all days (i.e., 54)
theDataSMP=cell2mat(SPFT_d0.scoredData.respSMP); 
errorbar(nanmean(theDataLRN),nanstd(theDataLRN)./sqrt(length(IDs)),'bo-','linewidth',2);
hold on;
errorbar(nanmean(theDataSMP),nanstd(theDataSMP)./sqrt(length(IDs)),'go-','linewidth',2);

plot([9.5 9.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([18.5 18.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([27.5 27.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([36.5 36.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([45.5 45.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([54.5 54.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
xlabel('Trial');
ylabel('Sensor Force Response (bar height)');

figure('name','Max lag autocorr');
theDataLRN=cell2mat(SPFT_d0.scoredData.lagLRN); %row=ID, column=trials across all days (i.e., 54)
theDataSMP=cell2mat(SPFT_d0.scoredData.lagSMP); 
errorbar(nanmean(theDataLRN),nanstd(theDataLRN)./sqrt(length(IDs)),'bo-','linewidth',2);
hold on;
errorbar(nanmean(theDataSMP),nanstd(theDataSMP)./sqrt(length(IDs)),'go-','linewidth',2);

plot([9.5 9.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([18.5 18.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([27.5 27.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([36.5 36.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([45.5 45.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([54.5 54.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
xlabel('Trial');
ylabel('Lag (ms)');


figure('name','Corr coef between current error and current force');
theDataLRN=cell2mat(SPFT_d0.scoredData.errorlagcorrLRN); %row=ID, column=trials across all days (i.e., 54)
theDataSMP=cell2mat(SPFT_d0.scoredData.errorlagcorrSMP); 
errorbar(nanmean(theDataLRN),nanstd(theDataLRN)./sqrt(length(IDs)),'bo-','linewidth',2);
hold on;
errorbar(nanmean(theDataSMP),nanstd(theDataSMP)./sqrt(length(IDs)),'go-','linewidth',2);

plot([9.5 9.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([18.5 18.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([27.5 27.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([36.5 36.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([45.5 45.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([54.5 54.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
xlabel('Trial');
ylabel('r');


figure('name','Norm ratio (amplitude diff)');
theDataLRN=cell2mat(SPFT_d0.scoredData.normrLRN); %row=ID, column=trials across all days (i.e., 54)
theDataSMP=cell2mat(SPFT_d0.scoredData.normrSMP); 
errorbar(nanmean(theDataLRN),nanstd(theDataLRN)./sqrt(length(IDs)),'bo-','linewidth',2);
hold on;
errorbar(nanmean(theDataSMP),nanstd(theDataSMP)./sqrt(length(IDs)),'go-','linewidth',2);

plot([9.5 9.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([18.5 18.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([27.5 27.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([36.5 36.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([45.5 45.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([54.5 54.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
xlabel('Trial');

figure('name','Speed accuracy tradeoff');
theDataLRN=cell2mat(SPFT_d0.scoredData.lagLRN)./cell2mat(SPFT_d0.scoredData.alignedrmseLRN); %row=ID, column=trials across all days (i.e., 54)
theDataSMP=cell2mat(SPFT_d0.scoredData.lagSMP)./cell2mat(SPFT_d0.scoredData.alignedrmseSMP); 
errorbar(nanmean(theDataLRN),nanstd(theDataLRN)./sqrt(length(IDs)),'bo-','linewidth',2);
hold on;
errorbar(nanmean(theDataSMP),nanstd(theDataSMP)./sqrt(length(IDs)),'go-','linewidth',2);

plot([9.5 9.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([18.5 18.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([27.5 27.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([36.5 36.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([45.5 45.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
plot([54.5 54.5], [min([nanmean(theDataLRN), nanmean(theDataSMP)]),max([nanmean(theDataLRN), nanmean(theDataSMP)])],'k:');
xlabel('Trial');
ylabel('Lag/RMSE');

%% Take a look at the overlap of all of the data for each individual (only currently showing the first day)

linewidths=(SPFT_d0.numTrials*SPFT_d0.numBlocks:-1:1)/SPFT_d0.numTrials*SPFT_d0.numBlocks*.3;
for ID=1:length(SPFT_d0.IDs)
    cmd=['rawForce=SPFT_d0.',SPFT_d0.IDs{ID},'.d1.out.SMP(:,4);']; %raw force
    eval(cmd);
    figure('name',[SPFT_d0.IDs{ID} ' (SMP rawForce)']);
    for trial=1:SPFT_d0.numTrials*SPFT_d0.numBlocks
        plot(rawForce{trial},'color', rand(1,3),'linewidth',linewidths(trial))
        if trial==1
            hold on;
        end
    end
end
for ID=1:length(SPFT_d0.IDs)
    cmd=['rawForce=SPFT_d0.',SPFT_d0.IDs{ID},'.d1 .out.LRN(:,4);'];
    eval(cmd);
    figure('name',[SPFT_d0.IDs{ID} ' (LRN rawForce)']);
    for trial=1:SPFT_d0.numTrials*SPFT_d0.numBlocks
        plot(rawForce{trial},'color', rand(1,3),'linewidth',linewidths(trial))
        if trial==1
            hold on;
        end
    end
end


%% BELOW HERE IS OLD CODE FOR SINGLE DAY OF DATA

%% DID NOT YET IMPLEMENT VEL ACC JRK
% XXX OLD, does not work for new data structure with multiple days

figure('name','Velocity');
plotVal1=temp.out.all.velLRN;
plotVal2=temp.out.all.velSMP;
errorbar(nanmean(plotVal1),nanstd(plotVal1)./sqrt(length(IDs)),'bo-','linewidth',2);
hold on
plot(1:SPFT_d0.numTrials*SPFT_d0.numBlocks,ones(1,SPFT_d0.numTrials*SPFT_d0.numBlocks)*mean(abs(diff(resample(SPFT_d0.LRN,1,SPFT_d0.resampleFactor)))),'b--');
errorbar(nanmean(plotVal2),nanstd(plotVal2)./sqrt(length(IDs)),'go-','linewidth',2);
plot(1:SPFT_d0.numTrials*SPFT_d0.numBlocks,ones(1,SPFT_d0.numTrials*SPFT_d0.numBlocks)*mean(abs(diff(resample(SPFT_d0.SMP,1,SPFT_d0.resampleFactor)))),'g--');

plotVal1=temp.out.all.accLRN;
plotVal2=temp.out.all.accSMP;
figure('name','Acceleration');
errorbar(nanmean(plotVal1),nanstd(plotVal1)./sqrt(length(IDs)),'bo-','linewidth',2);
hold on
plot(1:SPFT_d0.numTrials*SPFT_d0.numBlocks,ones(1,SPFT_d0.numTrials*SPFT_d0.numBlocks)*mean(abs(diff(diff(resample(SPFT_d0.LRN,1,SPFT_d0.resampleFactor))))),'b--');
errorbar(nanmean(plotVal2),nanstd(plotVal2)./sqrt(length(IDs)),'go-','linewidth',2);
plot(1:SPFT_d0.numTrials*SPFT_d0.numBlocks,ones(1,SPFT_d0.numTrials*SPFT_d0.numBlocks)*mean(abs(diff(diff(resample(SPFT_d0.SMP,1,SPFT_d0.resampleFactor))))),'g--');

plotVal1=temp.out.all.jrkLRN;
plotVal2=temp.out.all.jrkSMP;
figure('name','Jerk');
errorbar(nanmean(plotVal1),nanstd(plotVal1)./sqrt(length(IDs)),'bo-','linewidth',2);
hold on
plot(1:SPFT_d0.numTrials*SPFT_d0.numBlocks,ones(1,SPFT_d0.numTrials*SPFT_d0.numBlocks)*mean(abs(diff(diff(diff(resample(SPFT_d0.LRN,1,SPFT_d0.resampleFactor)))))),'b--');
errorbar(nanmean(plotVal2),nanstd(plotVal2)./sqrt(length(IDs)),'go-','linewidth',2);
plot(1:SPFT_d0.numTrials*SPFT_d0.numBlocks,ones(1,SPFT_d0.numTrials*SPFT_d0.numBlocks)*mean(abs(diff(diff(diff(resample(SPFT_d0.SMP,1,SPFT_d0.resampleFactor)))))),'g--');
%% Take a look at the relationship between the force that the subject provided and the error signal that was present at the time
% XXX Sep 22, 2014, changed this to look at the positive and negative lag
% negative = prediction
% positive = actual lag

fprintf('--- Extracting Error vs. Force data ---\n',IDs{ID});
var1=zeros(21,24);
var2=var1;
maxLRN=var1;
maxSMP=var1;

fdbkCorrLRN=var1;
fdbkCorrSMP=var1;

corrLRN=zeros(21,24); %single lag point correlation
corrSMP=var1;
meancorrLRN=corrLRN;
meancorrSMP=corrLRN;

errorLRN=zeros(length(SPFT_d0.IDs),SPFT_d0.numTrials,SPFT_d0.seqLength);
errorSMP=errorLRN;

%xcorr of error with itself
xcorrerrorLRN=zeros(length(SPFT_d0.IDs),SPFT_d0.numTrials,2879);
xcorrerrorSMP=xcorrerrorLRN;

cut=80;%25; %cut off the first number of samples 1 = all, 2 = cut the 1st one... etc
look_ahead_samples=80; %num samples to look forward in time for the maximum correlation, set to 0 for all (12.5ms per sample)
num_samples=(SPFT_d0.seqLength-cut)*2-1; %number of samples that will be in the output of the xcorr (only looking at -ve lag, i.e., prediction)

if look_ahead_samples==0
    xcLRN=zeros(length(SPFT_d0.IDs),length(SPFT_d0.numTrials),(num_samples+1)/2);
else
    xcLRN=zeros(length(SPFT_d0.IDs),length(SPFT_d0.numTrials),look_ahead_samples+1);
end

xcSMP=xcLRN;

for ID=1:length(IDs)
    fprintf('--- Processing %s ---\n',IDs{ID});
    temp.out.errorLRN=[];
    temp.out.errorSMP=[];
    temp.out.forceLRN=[];
    for trial=1:SPFT_d0.numBlocks*SPFT_d0.numTrials
        %fprintf('Trial %i\n',trial);
        try
            %downsample the data to the same temporal resolution as the
            %data that we are trying to match, then calculate our measures
            %of interest
            temp.LRNresp=resample(SPFT_d0.fullData(ID).out.LRN{trial,1},SPFT_d0.seqLength,length(SPFT_d0.fullData(ID).out.LRN{trial,1}));
            temp.SMPresp=resample(SPFT_d0.fullData(ID).out.SMP{trial,1},SPFT_d0.seqLength,length(SPFT_d0.fullData(ID).out.SMP{trial,1}));
            temp.out.errorLRN=[abs((temp.LRNresp-SPFT_d0.LRN))'];
            temp.out.forceLRN=[abs(diff(diff(temp.LRNresp)))'];
            temp.out.errorSMP=[abs((temp.SMPresp-SPFT_d0.SMP))'];
            temp.out.forceSMP=[abs(diff(diff(temp.SMPresp)))'];
            
            [xc lags]=xcorr(temp.out.errorLRN(cut:end-2),temp.out.forceLRN(cut:end),'coeff');
            xc_midpoint=(length(xc)+1)/2; %now we know what 1/2 way point is, this is the lag0 correlation point
            if look_ahead_samples==0
                [m lag_idx]=max(xc(xc_midpoint:end)); %only look within the # samples for max corr
            else
                [m lag_idx]=max(xc(xc_midpoint:xc_midpoint+look_ahead_samples)); %only look within the # samples for max corr
            end
            
            lag=90/80*lags(xc_midpoint+lag_idx)/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1;
            fprintf('Max correlation at lag of LRN: %.2f ms \n',lag);
            var1(ID,trial)=lag;
            maxLRN(ID,trial)=m;
            xcLRN(ID,trial,:)=xc(xc_midpoint:xc_midpoint+look_ahead_samples);
            corrLRN(ID,trial)=xc(xc_midpoint+lag_idx);
            meancorrLRN(ID,trial)=mean(abs(xc(xc_midpoint:end)));
            errorLRN(ID,trial,:)=temp.out.errorLRN;
            xcorrerrorLRN(ID,trial,:)=xcorr(temp.out.errorLRN,temp.out.errorLRN,'coeff');
            tt=xc;
            [xc lags]=xcorr(temp.out.errorSMP(cut:end-2),temp.out.forceSMP(cut:end),'coeff');
            xc_midpoint=(length(xc)+1)/2; %now we know what 1/2 way point is, this is the lag0 correlation point
            if look_ahead_samples==0
                [m lag_idx]=max(xc(xc_midpoint:end)); %only look within the # samples for max corr
            else
                [m lag_idx]=max(xc(xc_midpoint:xc_midpoint+look_ahead_samples)); %only look within the # samples for max corr
            end
            
            lag=90/80*lags(xc_midpoint+lag_idx)/SPFT_d0.seqLength*SPFT_d0.seqDur*1000*-1; %in ms
            fprintf('Max correlation at lag of SMP: %.2f ms \n',lag);
            var2(ID,trial)=lag;
            maxSMP(ID,trial)=m;
            xcSMP(ID,trial,:)=xc(xc_midpoint:xc_midpoint+look_ahead_samples);
            corrSMP(ID,trial)=xc(xc_midpoint+lag_idx);
            meancorrSMP(ID,trial)=mean(abs(xc(xc_midpoint:end)));
            errorSMP(ID,trial,:)=temp.out.errorSMP;
            xcorrerrorSMP(ID,trial,:)=xcorr(temp.out.errorSMP,temp.out.errorSMP,'coeff');
            %corrLRN(ID,trial)=tt(xc_midpoint+lag_idx);
            
        catch
            warning('%s trial %i was not scored properly\n',SPFT_d0.IDs{ID},trial);
        end
    end
end
% figure;plot(var1','xb');
% hold on; plot(var2','og');
% ylabel('Lag (ms)');
% xlabel('Trial');
% title(['Lag with maximum correlation between error and response change (vel)\nWindow of ' num2str(samples) ,'considered']);
% averageRT=mean(median([var1;var2]));
% averageRTSamples=averageRT/1000/SPFT_d0.seqDur*SPFT_d0.seqLength*80/90*-1;
% fprintf('Average of median RT to respond to error on SMP and LRN (given the window) in ms: %.2f \n Num samples offset (lag): %.2f\n',averageRT,averageRTSamples);

figure('name','Mean lag correlations across subjects');
subplot(2,2,1);
imagesc(squeeze(mean(xcLRN,1)));
c1=caxis; %get colour scale values
title('LRN xcorr')
ylabel('Trial (mean)');
subplot(2,2,2);
imagesc(squeeze(mean(xcSMP,1)));
caxis(c1);
title('SMP xcorr')
subplot(2,2,3);
imagesc(squeeze(std(xcLRN,1)));
caxis(c1);
ylabel('Trial (std)');
subplot(2,2,4);
imagesc(squeeze(std(xcSMP,1)));
caxis(c1);
xlabel('Sample number (relative to lag of 0)');
colorbar;

figure('name','Mean abs(error) across sequence');
subplot(2,2,1);
imagesc(squeeze(mean(abs(errorLRN),1)),[0,50]);
hold on;
plot(SPFT_d0.LRN/10,'k--','linewidth',2);
title('LRN')
c1=caxis;
subplot(2,2,2);
imagesc(squeeze(mean(abs(errorSMP),1)));
hold on;
%plot(SPFT_d0.SMP/10,'g--','linewidth',2);
title('SMP')
caxis(c1);
subplot(2,2,3);
plot(SPFT_d0.LRN,'b','linewidth',2);
subplot(2,2,4);
plot(SPFT_d0.SMP,'g','linewidth',2);
caxis(c1);
colorbar;

figure('name','Xcorr of error with itself')
subplot(2,2,1);
imagesc(squeeze(mean(xcorrerrorLRN(:,:,1441:end),1)));
hold on;
plot(SPFT_d0.LRN/10,'k--','linewidth',2);
title('LRN')
c1=caxis;
subplot(2,2,2);
imagesc(squeeze(mean(xcorrerrorSMP(:,:,1441:end),1)));
hold on;
plot(SPFT_d0.SMP/10,'k--','linewidth',2);
title('SMP')
caxis(c1);
subplot(2,2,3);
caxis(c1);
colorbar;

% figure;
% plot(xcLRN','b:'); hold on; plot(mean(xcLRN),'b-','linewidth',2);
% plot((length(mean(xcLRN))-1)/2,0,'ro'); plot([(length(mean(xcLRN))-1)/2,(length(mean(xcLRN))-1)/2],[-.4,.4],'r','Linewidth',2);
% xlabel('Sample')
% ylabel('xcorr')
% figure;
%
% plot(xcSMP','g:'); hold on; plot(mean(xcSMP),'g-','linewidth',2);
% plot((length(mean(xcSMP))-1)/2,0,'ro');plot([(length(mean(xcSMP))-1)/2,(length(mean(xcSMP))-1)/2],[-.4,.4],'r','Linewidth',2);
% xlabel('Sample')
% ylabel('xcorr')

figure('name','LRN - correlation change at max xcorr -lag');plot(corrLRN'); hold on; plot(mean(corrLRN),'ko-','Linewidth',3)
figure('name','SMP - correlation change at max xcorr -lag');plot(corrSMP'); hold on; plot(mean(corrSMP),'ko-','Linewidth',3)
xlabel('Trial');ylabel('Corr');
%detrended
%figure('name','detrended LRN - correlation change at max xcorr -lag');plot(detrend(corrLRN','constant')); hold on;plot(mean(detrend(corrLRN','constant'),2),'k','linewidth',3)
%figure('name','detrended SMP - correlation change at max xcorr -lag');plot(detrend(corrSMP','constant')); hold on;plot(mean(detrend(corrSMP','constant'),2),'k','linewidth',3)
