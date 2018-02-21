params1 = load('C:\GitRepositories\ClassifierTools\2018.02.20_params_branch.mat');
params2 = load('C:\GitRepositories\ClassifierTools\2018.02.20_params_master.mat');
struct1 = struct(params1.params);
struct2 = struct(params2.params);
% struct1.MDB.folderSwitchFcn = 1;
% struct2.MDB.folderSwitchFcn = 1;
struct1 = rmfield(struct1,'ratioToClassifier');
% struct1.HI = rmfield(struct1.HI,'Fs');
% struct1 = rmfield(struct1,'rate');
struct1 = rmfield(struct1,'ratioToController');
% struct1 = rmfield(struct1,'allFeatureNames');
% struct1 = rmfield(struct1,'corrOffset');
% struct1 = rmfield(struct1,'corrDownweightExponent');
% struct1 = rmfield(struct1,'maxDecrease');
n1 = fieldnames(struct1);

for ii = 1:length(n1)
    fprintf(['=====> ',n1{ii},' <=====\n'])
    if isstruct(struct1.(n1{ii}))
        n2 = fieldnames(struct1.(n1{ii}));
        if isfield(struct2,(n1{ii}))
            for jj = 1:length(n2)
                fprintf(['===> ',n2{jj},' <===\n'])
                if isfield(struct2.(n1{ii}),(n2{jj}))
                    comp_struct(struct1.(n1{ii}).(n2{jj})  ,  struct2.(n1{ii}).(n2{jj}));
                else
                    fprintf('The field is not present in struct2.\n')
                end
            end
        else
            fprintf('The field is not present in struct2.\n')
        end
    else
        comp_struct(struct1.(n1{ii}),struct2.(n1{ii}));
    end
end

% clear n1 n2
% rmfield(struct1,'allFeatureNames');
% n1 = fieldnames(struct1);
% for ii = 1:length(n1)
% if isstruct(struct1.(n1{ii}))
% n2 = fieldnames(struct1.(n1{ii}));
% for jj = 1:length(n2)
% if isfield(struct2.(n1{ii}),(n2{jj}))
% fprintf(['===> ',n2{jj},' <===\n'])
% comp_struct(struct1.(n1{ii}).(n2{jj})  ,  struct2.(n1{ii}).(n2{jj}));
% end
% end
% else
% comp_struct(struct1.(n1{ii}),struct2.(n1{ii}));
% end
% end