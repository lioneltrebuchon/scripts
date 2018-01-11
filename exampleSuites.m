%% Example Script to use to Unittest framework
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
task_ = 'HABS_6classes_regression';  % HABS_6classes_tiny HABS_6classes_regression
% jUnit report
filename = fullfile(ClasRoot,'log',[mfilename '.junit.xml']);
% Verbosity
runVerbosity = 2;


%% Examples
if exist(filename,'file')
    delete(filename)
end
suites_sel = [];
suites_all = []; % so as to
% Test all configuration files (could be limited to task)
if 1
    suite_all = TestSuite.fromPackage('unittest.Configuration');
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verifyFileStructure','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end
% Run Task
if 1
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('run','IgnoringCase',true)));
    % add to the main lists
    suites_all = [suites_all, suite_all];
    suites_sel = [suites_sel, suite_sel];
end
% Verify Results
if 1
    suite_all = TestSuite.fromPackage('unittest.TrainingTools');
    % Reduce to task only
    suite_all = suite_all.selectIf(HasParameter('Property','tasks','Value',task_));
    % Reduce to selection
    suite_sel = suite_all.selectIf(HasName(ContainsSubstring('verify','IgnoringCase',true)));
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
else
    error('no suite to be tested.')
end
