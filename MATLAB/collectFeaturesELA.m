function collectFeaturesELA(func,dim,ssize)

% -------------------------------------------------------------------------
% Preliminaries 
localSetup;                                                 % Run script with local setup
FILENAME = ['_D' num2str(dim) '_C' num2str(ssize) '.mat'];  % Parameters of the experiment
% -------------------------------------------------------------------------
% Test if we have the necessary data to calculate these features
if ~filexists([ROOTDIR 'X' FILENAME]) || ~filexists([ROOTDIR 'XX' FILENAME]) || ...
        ~filexists([ROOTDIR 'X2' FILENAME]) || ~filexists([ROOTDIR 'Hx' FILENAME])
   warning('Please collect latin hypercube and auxiliary data. Skipped.');
   return
end
% Loading the required data
X  = getfromfile([ROOTDIR 'X'  FILENAME],'X');
XX = getfromfile([ROOTDIR 'XX' FILENAME],'XX');
X2 = getfromfile([ROOTDIR 'X2' FILENAME],'X2');
Hxhat  = getfromfile([ROOTDIR 'Hx' FILENAME],'Hxhat');
Hx1hat = getfromfile([ROOTDIR 'Hx' FILENAME],'Hx1hat');
Hx2hat = getfromfile([ROOTDIR 'Hx' FILENAME],'Hx2hat');
% Variables for the experiment
ELA_FEATURES = 17;
DELTA = norm(10.*ones(dim,1));
% -------------------------------------------------------------------------
% Starting the function/instance run
t0 = clock;
for i=func % This allows for multiple functions with the same dimension and sample size
    % ---------------------------------------------------------------------
    % Test if we still need to calculate these features
    if filexists([ROOTDIR 'ELA_F' num2str(i) FILENAME])                     % The file exists
        if varexists([ROOTDIR 'ELA_F' num2str(i) FILENAME],'ELA')           % The variable exists
            if sum(varnonzero([ROOTDIR 'ELA_F' num2str(i) FILENAME],'ELA'))>15 % The variable is not all zeros
                disp(['ELA_F' num2str(i) FILENAME ' already processed.'])
                continue
            end
        end
    end
    if ~filexists([ROOTDIR 'Y_F' num2str(i) FILENAME])
        warning(['Please collect F' num2str(i) ' data. Skipped.']);
        continue
    end
    Y           = getfromfile([ROOTDIR 'Y_F' num2str(i) FILENAME],'Y');
    MAXINSTANCE = size(Y,1);
    ELA         = zeros(MAXINSTANCE,ELA_FEATURES);
    % Instance run
    for j=1:MAXINSTANCE
        % Calculating the ELA features
        ELA(j,:) = calcELA(X,XX,X2,Y(j,:),Hxhat,Hx1hat,Hx2hat,DELTA);
        disp(['-> F' num2str(i) ' ELA features calculated, elapsed time [h]: ' num2str(etime(clock, t0)/60/60,'%.2f')]);
    end
    if filexists([ROOTDIR 'ELA_F' num2str(i) FILENAME])
        save([ROOTDIR 'ELA_F' num2str(i) FILENAME],'-append','ELA');
    else
        save([ROOTDIR 'ELA_F' num2str(i) FILENAME],'ELA');
    end
    disp(['      date and time: ' num2str(clock, ' %.0f')]);
end
% =========================================================================
