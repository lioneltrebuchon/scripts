#-- Score the test sample using input model
score_on_test<-function(mdl,dm_test)
{
  require(mlr)
  require(data.table)
  pred = predict(mdl, newdata = dm_test)
  pred = as.data.table(pred)[order(-prob.1)]
  setnames(pred,"prob.1","pred_val")
  pred = pred[,.(truth,pred_val)]
  return(pred)
}


#-- Get the number of contacts per channel to decide whether we have enough contacts to train a model or not
getCampaigningCounts<-function(dt_res_cast_agg,availableChannels)
{
  #-- Get the available channels
  camp_stats = dt_res_cast_agg[,.N,by=availableChannels][order(-N)]
  
  #-- Get sum of touch points
  camp_stats[,totalTouchpoints:=0]
  for(ch in availableChannels)
  {
    camp_stats[,totalTouchpoints:=totalTouchpoints+get(ch)]
    
  }
  
  dt_channel_availability = data.table(channel=availableChannels, N_points=c(0))
  for(ch in availableChannels)
  {
    
    dt_channel_availability[channel==ch, N_points:=camp_stats[get(ch)==1 & totalTouchpoints == 1,N]]  
    
  }
  
  return(dt_channel_availability)
  
}

#-- Prepare DM for customer base scoring. This is done on the latest snapshot for all customers to 
#   obtain the scores
prepare_scoring_base<-function(eop)
{
  
  logit("Reading the datamart for the eop of "+eop)  
  #-- Read the DM for this month
  dir = data_inp_dir+"P300_Account_DNA.csv/EOP_YearMonth="+eop+"/"
  dm = read_csvs_in_dir(dir)
  
  #-- Assigning eop variable
  dm$eop=as.character(eop)
  
  logit("Filter to residential accounts")
  #-- Filter to the accounts that are relevant for this month and are Residential
  dm_sel = dm[Segment_Name =="Residential"]
  
  if(nrow(dm_sel)<1)
  {
    logit("No rows extracted from DM, probably campaign is on non-residential accounts",error = 1)  
  }
  
  
  setnames(dm_sel,lng_col_names$old_names,lng_col_names$new_names)
  
  
  logit("Getting age form Birth_Date")
  #-- Get age from Birthdate
  dm_sel[,eop_tmp:=as.Date(paste0(substr(eop,1,4),"-",substr(eop,5,7),"-28"))]
  dm_sel[,age:=interval(as.Date(as.Date(Birth_Date)),eop_tmp)/years(1)]
  #-- Clean wrong ages
  dm_sel[age>MAX_AGE | age<MIN_AGE ,age:=NA_integer_]
  #-- Delete tmp eop column and Birth Date
  dm_sel[,':='(eop_tmp=NULL,Birth_Date=NULL)]
  
  
  #-- Quantize X/Y coordinates before dummification
  dm_sel[,X_Coordinate:=floor(X_Coordinate/COORDINATE_PRECISION)]
  dm_sel[,Y_Coordinate:=floor(X_Coordinate/COORDINATE_PRECISION)]
  
  
  logit("Converting some numerical variables to characters")
  #-- Convert numeric variables to strings
  dm_sel[,(varsNum2Cat):= lapply(.SD, as.character), .SDcols = varsNum2Cat]
  
  #-- Get column types
  col_types = get_col_types(dm_sel)
  
  
  #--  DUMMIFY NON-NUMERIC --#
  
  key_column = find_key_ignoring_case(dm_mdl, get_config('datamart_key'))
  
  #-- Select non-numeric/integer/logical variables which are all predictors
  varsToDummify = setdiff(col_types[ !(type %in% c("integer","numeric","logical")), col_name ], c(nonPreds,vars2Del) )
  
  logit("Dummifying non-numerical columns")
  dt_dumm_cols = get_dummified_dt(dm_sel, vars_to_dummyfiy = varsToDummify, key_column = key_column)
  
  
  logit("Remove dummified columns")
  #-- Join dummified columns
  sel_cols = setdiff(names(dm_sel),c(varsToDummify,vars2Del) ) 
  dm_sel = merge(dm_sel[,..sel_cols],dt_dumm_cols,all.x=T,by=key_column)
  
  
  logit("Selecting only numeric columns [No characters]")
  col_types = get_col_types(dm_sel)
  
  
  #-- Select only numeric columns
  num_cols = col_types[type == "integer" |type == "numeric" |type == "logical",col_name]
  #-- Exclude non predictors
  num_cols = setdiff(num_cols)  # ,c("target"))
  dm_sel = dm_sel[,..num_cols]
  
  #-- Convert all to numeric
  dm_sel <- as.data.table(sapply( dm_sel, as.numeric ))
  
  #-- Change target to factor to do classification
  dm_sel[,target:=as.factor(target)]
  
  return(dm_sel)
  
}


#-- Read all csvs in a dir
read_csvs_in_dir <- function(dir)
{
  require(data.table)
  fls = list.files(path = dir)
  i=1
  while(i<(length(fls)+1))
  {
    
    if(i==1)
    {
      res = fread(paste0(dir,fls[i]))
    }else{
      res = rbind(res,fread(paste0(dir,fls[i])))
      
    }
    i=i+1
  }
  return(res)
}

load_monthly_P300_for_accounts_and_eop <- function(dt_custs_inscope, eop){
  #-- Manually setting EOP for testing
  #eop = eop_trn
  #eop = eop_tst
  
  logit("Getting unique accounts which are inscope for this eop")
  #-- Accounts which are relevant to this month
  accs_inscope = unique(dt_custs_inscope[Calendar_Date_month_1 == eop,Account_Id])
  
  logit("Reading the datamart for the eop of "+eop)  
  #-- Read the DM for this month
  dir = data_inp_dir+"P300_Account_DNA.csv/EOP_YearMonth="+eop+"/"
  dm = read_csvs_in_dir(dir)
  gc()
  
  #-- Assigning eop variable
  dm$eop=as.character(eop)
  
  logit("Filter to accounts in scope and residential accounts")
  #-- Filter to the accounts that are relevant for this month and are Residential
  dm_sel = dm[account_id %in% accs_inscope & Segment_Name =="Residential"]
  return(dm_sel)
}

#-- For a given EOP and target, read the dm and prepare it for modeling
prepare_dm <- function(eop,dt_custs_inscope, dt_res_cast_agg=NULL, target_uplift='target', load_P300=TRUE)
{
  #-- Manually setting EOP for testing
  #eop = eop_trn
  #eop = eop_tst
  if (load_P300){
    dm_sel = load_monthly_P300_for_accounts_and_eop(dt_custs_inscope, eop)
  }else{ # Expects the P300 datamart with the relevant customers in dt_custs_inscope
    dm_sel = copy(dt_custs_inscope[Calendar_Date_month_1 == eop])
    dm_sel$eop = as.character(eop)
  }
  
  if(nrow(dm_sel)<1)
  {
    logit("No rows extracted from DM, probably campaign is on non-residential accounts",error = 1)  
  }else{
    
    
    logit("Join the targets")
    #-- Join targets
    if (!is.null(dt_res_cast_agg)){
      dm_mdl = merge(dm_sel, dt_res_cast_agg[Calendar_Date_month_1==eop],all.x=T,by.x=c("account_id","eop"),by.y=c("Account_id","Calendar_Date_month_1"))
    }else{
      dm_mdl = dm_sel
    }
    
    #-- Define the target column
    setnames(dm_mdl,target_uplift,"target")
    
    logit("#-- CLEANING --#")
    
    #-- CLEANING --#
    logit("Shortening long column names to prepare for dummification")
    #-- Shorten long names
    setnames(dm_mdl,lng_col_names$old_names,lng_col_names$new_names)
    
    logit("Getting age form Birth_Date")
    #-- Get age from Birthdate
    dm_mdl[,eop_tmp:=as.Date(paste0(substr(eop,1,4),"-",substr(eop,5,7),"-28"))]
    dm_mdl[,age:=interval(as.Date(as.Date(Birth_Date)),eop_tmp)/years(1)]
    #-- Clean wrong ages
    dm_mdl[age>MAX_AGE | age<MIN_AGE ,age:=NA_integer_]
    #-- Delete tmp eop column and Birth Date
    dm_mdl[,':='(eop_tmp=NULL,Birth_Date=NULL)]
    
    
    #-- Quantize X/Y coordinates before dummification
    dm_mdl[,X_Coordinate:=floor(X_Coordinate/COORDINATE_PRECISION)]
    dm_mdl[,Y_Coordinate:=floor(X_Coordinate/COORDINATE_PRECISION)]
    
    
    logit("Converting some numerical variables to characters")
    #-- Convert numeric variables to strings
    dm_mdl[,(varsNum2Cat):= lapply(.SD, as.character), .SDcols = varsNum2Cat]
    
    #-- Get column types
    col_types = get_col_types(dm_mdl)
    
    #--  DUMMIFY NON-NUMERIC --#
    key_column = find_key_ignoring_case(dm_mdl, get_config('datamart_key'))
    
    #-- Select non-numeric/integer/logical variables which are all predictors
    varsToDummify = setdiff(col_types[ !(type %in% c("integer","numeric","logical")), col_name ], c(nonPreds,vars2Del) )
    
    logit("Dummifying non-numerical columns")
    dt_dumm_cols = get_dummified_dt(dm_mdl, vars_to_dummyfiy = varsToDummify, key_column = key_column)
    
    
    logit("Remove dummified columns")
    #-- Join dummified columns
    sel_cols = setdiff(names(dm_mdl),c(varsToDummify,vars2Del) ) 
    dm_mdl = merge(dm_mdl[,..sel_cols],dt_dumm_cols,all.x=T,by=key_column)
    
    
    logit("Selecting only numeric columns [No characters]")
    col_types = get_col_types(dm_mdl)
    
    #-- Select only numeric columns
    num_cols = col_types[type == "integer" |type == "numeric" |type == "logical",col_name]
    #-- Exclude non predictors
    num_cols = setdiff(num_cols,c(key_column)) # ,"target")
    dm_mdl = dm_mdl[,..num_cols]
    
    #-- Convert all to numeric
    dm_mdl <- as.data.table(sapply( dm_mdl, as.numeric ))
    
    #-- Change target to factor to do classification
    dm_mdl[,target:=as.factor(target)]
    
    return(dm_mdl)
  }
  return(-1)
}


#-- Train a model based on current datamart
# PS: ALl cols need to be numeric
# target column should be called "target"
# "target" should be a factor of binary type
# balance_rate:
# if balance_rate<0 -> undersampling
# balance_rate >1 -> oversampling

get_trained_model<-function(dm_trn, clf = "classif.xgboost", balance_rate=1)
{
  require(mlr)
  logit("#-- MODELLING --#")
  #-- Define the task
  task = makeClassifTask( data = as.data.frame(dm_trn), target ="target")
  
  #-- Define the learner
  lrn = makeLearner(clf, predict.type = "prob")
  
  #-- TODO: Set hyperparameters
  #lrn = setHyperPars(lrn, eta = 0.01, max_depth = 3, nrounds=200, colsample_bytree=0.7, subsample=0.8)  
  lrn = setHyperPars(lrn, eta = 0.05, max_depth = 3, nrounds=50, colsample_bytree=0.7)  
  
  #-- Under/oversampling
  if(balance_rate!=1)
  {
    if(balance_rate<0) # Undersampling
    {
      lrn = makeUndersampleWrapper(lrn, usw.rate = 1/abs(balance_rate))
    }else{# Oversampling
      if(balance_rate>1)
      {
        lrn = makeOversampleWrapper(lrn, osw.rate = balance_rate)
      }
    }
    
  }
  
  #-- Train the model
  mdl = mlr::train(lrn, task)
  
  return(mdl)
}


#-- Plot the feature importance of an xgboost model
plot_xsb_ft_imp <- function(mdl,nms, N_feats=10)
{
  require(xgboost)
  require(mlr)
 
  if(is.null(getLearnerModel(mdl, more.unwrap = FALSE)$learner.model))
  {
    xgb1 = getLearnerModel(mdl, more.unwrap = FALSE)
  }else{
    xgb1 = getLearnerModel(mdl, more.unwrap = FALSE)$learner.model
  }
  
  
   #mat <- xgb.importance(feature_names = nms,model = xgb1)
  mat <- xgb.importance(model = xgb1)
  xgb.plot.importance(importance_matrix = mat[1:N_feats]) #first 20 variables
  
  
}


#-- Get lifts
get_lft <- function(pred,N)    
{
  require(data.table)
  quantile_size = floor(nrow(pred)/N)
  
  rnd_conv = sum(pred$truth)/nrow(pred)
  
  lft = data.table(qnt = seq(1:N) ,lift=1)
  j=1
  while(j<N)
  {
    curr_conv = sum(pred[(1+quantile_size*(j-1))  :(j*quantile_size),truth])/quantile_size
    
    lft[j,lift:=curr_conv/rnd_conv]
    
    j=j+1 
  }
  return(lft)
}

