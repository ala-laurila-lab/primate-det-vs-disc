% fitNakaRushton2.m
%
%        $Id:$ 
%      usage: fit = fitNakaRushton(c, r, fixed)
%         by: justin gardner
%       date: 12/24/13
%    purpose: fit a naka-rushton to data (taken from selectionModel)
%   modified: 2021 by Johan Westö 
%    version: Two parameters (c50 and n)
function [fit, resnorm, se, params] = fitNakaRushton2(c, r)

% check arguments
if nargin < 2
  help fitNakaRushton2
  return
end

% find contrast that evokes closest to half-maximal response
rMid = ((max(r)-min(r))/2) + min(r);
[~, rMidIndex] = min(abs(r-rMid));
initC50 = c(rMidIndex(1));

% use log contrasts to get better CI estimates for c50
initC50log = log10(initC50);
clog = log10(c);
clog(c==0)=-10;

% parameters [c50log        n]
initParams = [initC50log    2];
minParams =  [-10           0];
maxParams =  [3             5];

% optimization parameters
maxiter = inf;
optimParams = optimset('MaxIter', maxiter, 'TolFun', 1e-12, 'Display', 'off');

% now go fit
[params resnorm residual exitflag output lambda jacobian] = ...
  lsqnonlin(@nakaRushtonResidual, ...
  initParams, minParams, maxParams, optimParams, clog, r);

% Compute the se for the parameters values manually
% https://www.graphpad.com/guides/prism/latest/curve-fitting/reg_how_standard_errors_are_comput.htm
% Gives the same result as nlparseci below
df = numel(residual)-numel(params);
ss = residual'*residual;
cov_app = inv(jacobian'*jacobian);
se = diag( sqrt( cov_app * (ss/df) ) );

% Get the standard errors and confidence intervals using nlparseci
% [se, ci] = nlparseci(params, residual, 'jacobian', jacobian);

% parse params and return      
fit = parseParams(params);
fit.c50 = 10^fit.c50;         % return C50 insted of C50log

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    nakaRushtonResidual   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function residual = nakaRushtonResidual(params, c, r)

% decode parameters
p = parseParams(params);
% calculate naka-rushton
fitR = nakaRushton(c, p); 

residual = r(:) - fitR(:);
residual = residual(:);

%%%%%%%%%%%%%%%%%%%%%
%    nakaRushton   %
%%%%%%%%%%%%%%%%%%%%%
function response = nakaRushton(c, p)

% response = (p.Rmax-p.offset) * ((c.^p.n) ./ ((c.^p.n) + p.c50.^p.n)) + p.offset;
response = (p.Rmax-p.offset) * 1 ./ ( 1 + ( (10.^p.c50) ./ (10.^c) ).^p.n ) + p.offset;

%%%%%%%%%%%%%%%%%%%%%
%    parseParams    %
%%%%%%%%%%%%%%%%%%%%%
function p = parseParams(params)

p.Rmax = 1;
p.offset = 0.5;
p.c50 = params(1);
p.n = params(2);


  

