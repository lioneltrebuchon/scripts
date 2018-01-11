%% Example Script to use to Unittest framework
% Code lines - 44.
% WARNING: depending on the test selections the order can be wrong!!!
clear all
close all
clc

% Import libraries, do not touch me
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;
% import matlab.unittest.plugins.FailureDiagnosticsPlugin
% import matlab.unittest.selectors.HasTag; % Matlab 2016
import matlab.unittest.selectors.HasParameter;
import matlab.unittest.selectors.HasName;
import matlab.unittest.constraints.ContainsSubstring


%% Parametrization, do touch me
% Task
task_ = 'HABS_6classes_Mickey';
% test phase
activated_phase = 'split'; % features, split or train
force_skip = 0;
% jUnit report (change to custom filename if needed)
filename = fullfile(ClasRoot,'log',[mfilename '.junit.xml']);
% Verbosity (reduce/increase verbosity if needed)
runVerbosity = 1;


%% Setup
if exist(filename,'file')
    delete(filename)
end
suites_sel = [];
suites_all = []; % so as to


%% Phase "feature"
if strcmp(activated_phase, 'feature')
    % Run Task
    suite_all = TestSuite.fromClass(?unittest.TrainingTools.FeatureCalculation);
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to mode "run"
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('run','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];

    % Verify Results
    suite_all = TestSuite.fromClass(?unittest.TrainingTools.FeatureCalculation);
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to mode "run"
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verify','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
elseif force_skip
    % Skip
    suite_all = TestSuite.fromClass(?unittest.TrainingTools.FeatureCalculation);
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to mode "run"
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('skip','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end


%% Phase "split"
if strcmp(activated_phase, 'split')
    % Run Task
    if 1
        suite_all = TestSuite.fromClass(?unittest.TrainingTools.SplitTrainTest);
        % Reduce to task only
        suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
        % Reduce to mode "run"
        suite_sel = suite_all.selectIf(HasName(ContainsSubstring('run','IgnoringCase',true)));
        % add to the main lists
        suites_all = [suites_all, suite_all];
        suites_sel = [suites_sel, suite_sel];
    end
    % Verify Results
    if 1
        suite_all = TestSuite.fromClass(?unittest.TrainingTools.SplitTrainTest);
        % Reduce to task only
        suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
        % Reduce to mode "run"
        suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verify','IgnoringCase',true)));
        % add to the main lists
        suites_all = [suites_all, suite_all];
        suites_sel = [suites_sel, suite_sel];
    end
elseif force_skip
    % Skip
    suite_all = TestSuite.fromClass(?unittest.TrainingTools.SplitTrainTest);
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to mode "run"
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('skip','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end


%% Phase "train"
if strcmp(activated_phase, 'train')
    % Run Task
    if 1
        suite_all = TestSuite.fromClass(?unittest.TrainingTools.TrainTestMaster);
        % Reduce to task only
        suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
        % Reduce to mode "run"
        suite_sel = suite_all.selectIf(HasName(ContainsSubstring('run','IgnoringCase',true)));
        % add to the main lists
        suites_all = [suites_all, suite_all];
        suites_sel = [suites_sel, suite_sel];
    end
    % Verify Results
    if 1
        suite_all = TestSuite.fromClass(?unittest.TrainingTools.TrainTestMaster);
        % Reduce to task only
        suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
        % Reduce to mode "run"
        suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verify','IgnoringCase',true)));
        % add to the main lists
        suites_all = [suites_all, suite_all];
        suites_sel = [suites_sel, suite_sel];
    end
end


%% Run Suites
if ~isempty(suites_sel)
    runner = TestRunner.withTextOutput('Verbosity',runVerbosity);
    plug = unittest.jUnitPlugin(mfilename,filename,suites_all);
    runner.addPlugin(plug)
    %runner.addPlugin(FailureDiagnosticsPlugin)
    res = runner.run(suites_sel);
else
    error('no suite to be tested.')
end
