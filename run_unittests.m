%% Example Script to use to Unittest framework
% Code lines - 44.
% WARNING: depending on the test selections the order can be wrong!!!
clear all
close all
clc

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
task_ = 'HABS_6classes_tiny';  % HABS_6classes_tiny HABS_6classes_regression HABS_6classes_Venture HABS_6classes_Mickey
% jUnit report
filename = fullfile(ClasRoot,'log',[mfilename '.junit.xml']);
% Verbosity
runVerbosity = 2;
% MKL compatible (correct processor dependencies)
mkl_cmp = true;
if mkl_cmp
    setenv('MATLAB_DISABLE_CBWR','1');
    setenv('MKL_CBWR','COMPATIBLE');
    NrTh = maxNumCompThreads(4);
end
% enable phases
% 
test_config = 1;
test_reference = 0;
test_feature = 0;
test_split = 0;
test_train = 0;
test_export = 0;
% Enable Skip
skipTasks = false;


%% Examples
if exist(filename,'file')
    delete(filename)
end
suites_sel = [];
suites_all = []; % so as to

% Test all configuration files (could be limited to task)
if test_config
    suite_all = TestSuite.fromPackage('unittest.Configuration');
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verifyFileStructure','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end


%% ReferencePackages
% Run ReferencePackages
if test_reference
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('run','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('ReferencePackages','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
elseif skipTasks
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

% verify ReferencePackages
if test_reference
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verify','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('ReferencePackages','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end


%% FeatureCalculation
% Run FeatureCalculation
if test_feature
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('run','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('FeatureCalculation','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
elseif skipTasks
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

% Verify FeatureCalculation
if test_feature
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verify','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('FeatureCalculation','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end


%% SplitTrainTest
% Run SplitTrainTest
if test_split
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('run','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('SplitTrainTest','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
elseif skipTasks
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('skip','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('SplitTrainTest','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end

% Verify SplitTrainTest
if test_split
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


%% TrainTestMaster
% Run TrainTestMaster
if test_train
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('run','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('TrainTestMaster','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
elseif skipTasks
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('skip','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('TrainTestMaster','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end

% Verify TrainTestMaster
if test_train
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verify','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('TrainTestMaster','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end


%% ExportTraining
% Run ExportTraining
if test_export
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('run','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('ExportTraining','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
elseif skipTasks
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('skip','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('ExportTraining','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end

% Verify ExportTraining
if test_export
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verify','IgnoringCase',true)));
    suite_sel = suite_sel.selectIf(HasName(ContainsSubstring('ExportTraining','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
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
