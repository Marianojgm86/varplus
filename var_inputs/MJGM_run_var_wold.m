%% WOLD SHOCKS IRFs
% Tomas Caravello, Alisdair McKay, and Christian Wolf
% this version: 09/03/2024

%% HOUSEKEEPING
 
clc
clear all
close all

warning('off','MATLAB:dispatcher:nameConflict')

path = 'C:\Users\USUARIO\OneDrive - University of Leicester\Documents\GitHub\varplus\varplus';
vintage = '';
task = '/var_inputs';

addpath([path vintage '/_auxiliary_functions'])
addpath([path vintage task '/_data/main'])

save_results = 1;

cd([path vintage task]);

%% DATA
    % 1 'i'           
    % 2 'i_star'      
    % 3 'D4L_cpi'     
    % 4 'D4L_ner'     
    % 5 'D4L_MB'      
    % 6 'D4L_REM'     
    % 7 'D4L_pet'     
    % 8 'gdp_gap_star'
    % 9 'gdp_gap'     

% import data
data0 = databank.fromCSV("_data\main\VAR.csv");
dataGT = databank.fromCSV("_data\main\Processed_data.csv");
% Limiting range => Remittances 2003M01:2024m09
rng = mm(2003,1):mm(2024,9);
dataGT.L_MB = log(dataGT.MB.x12);

% raw macro outcomes
pet_       = dataGT.D4L_pet(rng).data;
ffr_       = dataGT.i_star(rng).data;
infl_      = dataGT.D4L_cpi(rng).data;
ner_       = dataGT.D4L_ner(rng).data;
igt_       = dataGT.i(rng).data;
gdp_       = dataGT.L_gdp_sa(rng).data;
mb_        = dataGT.L_MB(rng).data;
gdp_ext_   = dataGT.L_gdp_index_star(rng).data;
rem_       = dataGT.L_REM(rng).data;

% Hamilton Filter transformations
gdp_        = stat_transform(gdp_,1);
mb_         = stat_transform(mb_,1);
gdp_ext_    = stat_transform(gdp_ext_,1);
rem_        = stat_transform(rem_,1);

vardata_ = [ffr_ pet_ gdp_ext_ rem_ gdp_ infl_ ner_ mb_ igt_]; 
vardata_ = vardata_(12:end, :);
series_names = {'FFR', 'Pet', 'Output_star', 'Remmitances','Output',...
    'Inflation', 'NER', 'Money Base', 'Interest Rate'};

%% SETTINGS

n_lags     = 4;                    % number of lags
constant   = 0;                    % constant? 0: no constant, 1: just constant, 2: constant and linear trend.
                                   % (no need since already de-trended data)

IRF_hor    = 250;
n_draws    = 1000;
n_y        = size(vardata_,2);

%% VAR ESTIMATION

%----------------------------------------------------------------
% Estimate Reduced-Form VAR
% Aqui estiman usando metodos bayesianos en la funcion bvar_fn
% Obtienen la distribucion posterior para B (B_draws) y para Sigma
% (Sigma_draws)
% Que matrices son exactamente B y Sigma???
%----------------------------------------------------------------

% Prior is very loose so this is essentially equivalent to standard VAR.

T = size(vardata_,1) - n_lags;
[B_draws,Sigma_draws,B_OLS,Sigma_OLS] = bvar_fn(vardata_,n_lags,constant,n_draws);

%----------------------------------------------------------------
% OLS Wold IRFs
%----------------------------------------------------------------

% extract VAR inputs
% Sigma_u es la matriz varianza - covarianza de los residuos de la forma reducida    
Sigma_u   = Sigma_OLS;
% B es la matriz de coeficientes de la forma reducida
B         = B_OLS;

% benchmark rotation: since we need an arbitrary rotation, we just use
% cholesky, but any other will do, ordering does not matter here.

bench_rot = chol(Sigma_u,'lower');

% Wold IRFs

IRF_Wold = zeros(n_y,n_y,IRF_hor); % row is variable, column is shock
% Ref pag 27 kilian y lutkepohl. La primera IRF es una I.
IRF_Wold(:,:,1) = eye(n_y);
% Funciones Impulso Respuesta - Matrices de coeficientes para la
% Representacion MA
for l = 1:IRF_hor
    % Ref pagina 26 libro de Kilian y Lutkepohl.
    % Suma Recursiva de IRFs
    if l < IRF_hor
        for j=1:min(l,n_lags)
            IRF_Wold(:,:,l+1) = IRF_Wold(:,:,l+1) + B(1+(j-1)*n_y:j*n_y,:)'*IRF_Wold(:,:,l-j+1);
        end
    end
    
end

W = bench_rot;

%% get IRFs
% Reference Page 111 Kilian & Lutktepohl. 
% Using as B = chol(Sigma_u) 
% Uses the Cholesky decomposition to obtain structural IRFs?

IRF_OLS = NaN(n_y,n_y,IRF_hor);
for i_hor = 1:IRF_hor
    IRF_OLS(:,:,i_hor) = IRF_Wold(:,:,i_hor) * W;
end

% collect results

IS.Theta_OLS = squeeze(IRF_OLS);

%% ----------------------------------------------------------------
% Wold IRFs
%----------------------------------------------------------------

IS.Theta     = NaN(n_y,n_y,IRF_hor,n_draws);
IS.Theta_med = NaN(n_y,n_y,IRF_hor);
IS.Theta_lb  = NaN(n_y,n_y,IRF_hor);
IS.Theta_ub  = NaN(n_y,n_y,IRF_hor);

% do the same for each posterior draw.

for i_draw = 1:n_draws

% extract VAR inputs
    
Sigma_u   = Sigma_draws(:,:,i_draw);
B         = B_draws(:,:,i_draw);

% benchmark rotation

bench_rot = chol(Sigma_u,'lower');

% Wold IRFs

IRF_Wold = zeros(n_y,n_y,IRF_hor); % row is variable, column is shock
IRF_Wold(:,:,1) = eye(n_y);

for l = 1:IRF_hor
    
    if l < IRF_hor
        for j=1:min(l,n_lags)
            IRF_Wold(:,:,l+1) = IRF_Wold(:,:,l+1) + B(1+(j-1)*n_y:j*n_y,:)'*IRF_Wold(:,:,l-j+1);
        end
    end
    
end

W = bench_rot;

% get IRFs

IRF_idraw = NaN(n_y,n_y,IRF_hor);
for i_hor = 1:IRF_hor
    IRF_idraw(:,:,i_hor) = IRF_Wold(:,:,i_hor) * W;
end

% collect results

IS.Theta(:,:,:,i_draw) = squeeze(IRF_idraw);

end

% compute percentiles

for ii=1:n_y
    for jj=1:n_y
        for kk = 1:IRF_hor
            IS.Theta_med(ii,jj,kk) = quantile(IS.Theta(ii,jj,kk,:),0.5);
            IS.Theta_lb(ii,jj,kk) = quantile(IS.Theta(ii,jj,kk,:),0.16);
            IS.Theta_ub(ii,jj,kk) = quantile(IS.Theta(ii,jj,kk,:),0.84);
        end
    end
end

% re-shuffle ordering for plots

IS.Theta_med = permute(IS.Theta_med,[3 1 2]); % order: horizon, variable, shock
IS.Theta_lb  = permute(IS.Theta_lb,[3 1 2]);
IS.Theta_ub  = permute(IS.Theta_ub,[3 1 2]);

%% COMPUTE SECOND-MOMENT RESULTS

% VMA-implied variance-covariance matrix

IS.cov = zeros(n_y,n_y);
for i_hor = 1:IRF_hor
    IS.cov = IS.cov + IS.Theta_OLS(:,:,i_hor) * IS.Theta_OLS(:,:,i_hor)';
end

%% correlations

IS.corr = zeros(n_y,n_y);
for i_y = 1:n_y
    for ii_y = 1:n_y
        IS.corr(i_y,ii_y) = IS.cov(i_y,ii_y)/sqrt(IS.cov(i_y,i_y) * IS.cov(ii_y,ii_y));
    end
end

%% frequency bands

omega_1 = (2*pi)/32;
omega_2 = (2*pi)/6;

IS.freq_var = diag(freq_var_fn(IS.Theta_OLS,omega_1,omega_2));

%% SAVE RESULTS

if save_results == 1

    IS_wold = IS;
    
    cd([path vintage task '/_results_mjgm']);
    
    save wold_results IS_wold series_names
    
    cd([path vintage task]);

end