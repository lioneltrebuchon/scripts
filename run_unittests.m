%% Example Script to use to Unittest framework
% WARNING: depending on the test selections the order can be wrong!!!
clear all
close all
clc

% make environment CBWR-compatible in order to avoid e-24 precision errors
mkl_cmp = true;
if mkl_cmp
    setenv('MATLAB_DISABLE_CBWR','1');
    setenv('MKL_CBWR','COMPATIBLE');
    NrTh = maxNumCompThreads(4);
end

% Import libraries
import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;
% import matlab.unittest.plugins.FailureDiagnosticsPlugin
% import matlab.unittest.selectors.HasTag; % Matlab 2016
import matlab.unittest.selectors.HasParameter;
import matlab.unittest.selectors.HasName;
import matlab.unittest.constraints.ContainsSubstring


%% Parametrization
% Task
task_ = 'HABS_6classes_regression';  % HABS_6classes_tiny HABS_6classes_regression HABS_6classes_Venture HABS_6classes_Mickey
% jUnit report
filename = fullfile(ClasRoot,'log',[mfilename '.junit.xml']);
% Verbosity
runVerbosity = 2;
timeTicCounter = zeros(1,3);


%% Examples
if exist(filename,'file')
    delete(filename)
end
suites_sel = [];
suites_all = [];

% Test all configuration files (could be limited to task)
if 1
    suite_all = TestSuite.fromPackage('unittest.Configuration');
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verifyFileStructure','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end

% Copy ReferenceParcours reference data for audio and features (alias skip)
if 1
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('skip','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('ReferencePackages','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end

% Copy Training reference data for audio and features (alias skip)
if 1
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('skip','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('FeatureCalculation','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end

% Run SplitTrainTest
if 0
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('run','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('SplitTrainTest','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end

% Verify SplitTrainTest
if 0
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verify','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('SplitTrainTest','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end

% Run and Verify SplitTrainTest
if 1
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('SplitTrainTest','IgnoringCase',true)));
    suite_sel_run = suite_sel.selectIf(HasName(ContainsSubstring('run','IgnoringCase',true)));
    suite_sel_verify = suite_sel.selectIf(HasName(ContainsSubstring('verify','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel_run, suite_sel_verify];
end

%% Run Suites
if ~isempty(suites_sel)
    runner = TestRunner.withTextOutput('Verbosity',runVerbosity);
    plug = unittest.jUnitPlugin(mfilename,filename,suites_all);
    runner.addPlugin(plug)
    %runner.addPlugin(FailureDiagnosticsPlugin)
    res = runner.run(suites_sel);
    table(res)
else
    error('no suite to be tested.')
end