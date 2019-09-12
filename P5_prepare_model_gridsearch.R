# Last modified: 11.09.2019
rm(list = ls())
gc()

###########################################
#--      LIBRARIES                      --#
###########################################
# Set the libraries in the proper order
if(grepl(Sys.info(),"Linux")){
  .libPaths( c("/usr/lib64/R/library", "/usr/share/R/library", "/home/trebuchon/R/x86_64-redhat-linux-gnu-library/3.6" ) )
}
library(data.table)
library(stringr)
# In case you have conflicts with packages (a function does not work and you do not know why) look at this output.
# conflicts(detail=TRUE)
devtools::load_all(".")
get <- base::get

###########################################
#--      PARAMS                      --#
###########################################
#-- Directories
data_inp_dir <<- "data/input/"
data_int_dir <<- "data/intermediate/"
data_out_dir <<- "data/output/"
funcs_dir <<- "R/"
fig_dirs <<- "figs/"
mdls_dir <<-"models/"
scores_dir <<- "scores/"

###########################################
#--      LOAD DATA                      --#
###########################################
# collect_data_from_EBD
# Should be run first, from Rspark in terminal or in Zeppelin

start_date = 201904
end_date = 201909
# source('R/set_params.R') # Happens at load ;) 

#-- Load the account_DNA
freq = 'month'
file_path = wrap_folder_name('input_path', get_config('datamart_name'))
dat_w <- load_data(file_path=file_path, start_date=start_date, end_date=end_date, freq=freq)
dat_w = dat_w[Segment_Name =="Residential"]
account_key = find_key_ignoring_case(dat_w, get_config('datamart_key'))
date_key = find_key_ignoring_case(dat_w, get_date_id_name(freq))

#-- Define months of interest
eops = unique(dat_w[, get(date_key)])

#-- Load target table
name_target = "cnt_Fiber_Order" # TODO parametrize
path_target = wrap_folder_name('input_path', 'prd_fadm.P300_Fiber_Orders_Daily.csv')
dat_copper <- load_data(path_target, start_date=EOP_Yearmonth_to_date(start_date), end_date=EOP_Yearmonth_to_date(end_date+2), freq='day')

###########################################
#--      TARGETS                      --#
###########################################

if (freq=='month'){
  dat_copper <- d_to_m(dat_copper)
}
account_key_copper = find_key_ignoring_case(dat_copper, get_config('datamart_key'))
date_key_copper = find_key_ignoring_case(dat_copper, get_date_id_name(freq))

#-- Clean target
dat_copper <- dat_copper[, (name_target) := as.numeric(get(name_target) > 0)]
dat_copper <- dat_copper[, c(account_key_copper, date_key_copper, name_target), with=FALSE] # Naming convention not proper

#-- Join target into account_DNA (maybe faster to do it inside while loop)
dat_w <- merge(dat_w, dat_copper, by.x=c(account_key, date_key), by.y=c(account_key_copper, date_key_copper), all.x=TRUE)
# dat_w[is.na(name_target), get(name_target)] <- 0

#-- Properly assign target to date_key
dat_w = create_propensity_target_variable(dat_w, name_target, freq=freq)
name_target = paste0("target_", name_target)

###########################################
#--      MODEL CREATION                      --#
###########################################

#-- Select hyperparameters to search for
hypParams_sel = hypParams[sample(nrow(hypParams),N_hyperparams),]

#-- Rename to Mo convention
setnames(dat_w, account_key, "Account_id")
setnames(dat_w, date_key, "Calendar_Date_month_1")

#-- Define customers in copper to fiber scope
dat_w = dat_w[cnt_WIN > 0 & Segment_Name =="Residential"] # TODO should we segment by flg_Fiber_Access_Possible?  # & dat_w$Fiber == 0

#-- Define months of interest
eops = unique(dat_w[, Calendar_Date_month_1])
lfts_vec = c()

#-- Initialize summary table
dt_summary = data.table(eop_test=character(),channel=character(),lift=numeric(),
                        n_train=integer(),n_test=integer(),conversion_train=numeric(),
                        conversion_test=numeric(), nrounds=integer(), eta=numeric(),
                        max_depth=integer(),colsample_bytree=numeric(), balance_rate=integer(),
                        subsample=numeric())

topDecileGain = c()

i = 1
while(i<length(eops))
{
  #-- EOPS of train and test
  eop_trn = eops[i]
  eop_tst = eops[i+1]
  
  #-- TODO: Get prepared dm from previous month to save time - not needed when load_P300 is false
  
  #-- Prepare training set
  logit(paste0("Train: ", eop_trn))
  if (i == 1){
    dm_trn = copy(dat_w[Calendar_Date_month_1 == eop_trn & Cnt_Fiber_Access_Used == 0 ])
    dm_trn = prepare_dm(eop_trn, dm_trn, dt_res_cast_agg=NULL, name_target, load_P300=FALSE)
  }else{
    dm_trn = dm_tst
  }
  logit(paste("Train pool", eop_tst, ": No Xsell vs Xsell success", table(dm_trn$target)))
  
  #-- Prepare test set
  logit(paste0("Test: ", eop_tst))
  dm_tst = copy(dat_w[Calendar_Date_month_1 == eop_tst & Cnt_Fiber_Access_Used == 0 ])
  dm_tst = prepare_dm(eop_tst, dm_tst, dt_res_cast_agg=NULL, name_target, load_P300=FALSE)
  logit(paste("Test pool", eop_tst, ": No Xsell vs Xsell success", table(dm_tst$target)))
  
  #-- Add missing dummified columns
  expectedColumns = names(dm_trn)
  missing_cols = setdiff(expectedColumns,names(dm_tst))
  for (nm in missing_cols) dm_tst[,(nm):=0]
  
  j=1
  while(j<(1+nrow(hypParams_sel))){
    set.seed(seed)
    logit("Paramset "+j+" out of "+nrow(hypParams_sel))
    #-- Selecting current hyperparameter set
    params = hypParams_sel[j,]
  
    #-- Train a model
    mdl = get_tuned_trained_model(dm_trn, clf = "classif.xgboost", params)
  
    #-- Plot feature importance
    if(PLT_FT_IMP)
    {
      xgb1 = getLearnerModel(mdl, more.unwrap = FALSE)$learner.model
      #plot_xsb_ft_imp(xgb1,names(dm_trn))
      plot_xsb_ft_imp(xgb1)
    }
    
    #-- Score the test datamart set
    pred = score_on_test(mdl,as.data.frame(dm_tst[,..expectedColumns]))
    pred$truth = as.numeric(pred$truth)
    pred$pred_val = as.numeric(pred$pred_val)
  
    #-- Get lifts table
    lft = get_lft(pred,SCORE_GROUPS)
    
    #-- Append results
    topDecileGain = c(topDecileGain,lft[1,lift])
    
    #-- Append to summary table
    test_eop = eop_tst
    
    rowToAppend =list(test_eop, "campaignNone channelNone", lft[1,lift],nrow(dm_trn), nrow(dm_tst),100*nrow(dm_trn[target>0]) /nrow(dm_trn) ,100*nrow(dm_tst[target>0]) /nrow(dm_tst),
                      params$nrounds, params$eta,params$max_depth,params$colsample_bytree, params$balance_rate,params$subsample )
    dt_summary = rbind(dt_summary, rowToAppend )
    
    cat("--------------------------------------------\n")
    print(lft[1:2,])
    
    if(IN_MONTH_CV)
    {
      #--
      rdesc = makeResampleDesc(method = "CV", stratify = TRUE)
      
      r = resample(learner = lrn, task = task, resampling = rdesc,
                   show.info = FALSE, measures=auc, models = T)
      print(r)  
      xgb1 = r$models[[1]]$learner.model
      
      mat <- xgb.importance(feature_names = colnames(dm_mdl),model = xgb1)
      xgb.plot.importance(importance_matrix = mat[1:20]) #first 20 variables
      
    }
  
    lfts_vec = c(lfts_vec,lft[1,lift])
    j=j+1
  }
  i=i+1
}


###########################################
#--      SAVE LATEST MODEL             --#
###########################################

xgb.save(getLearnerModel(mdl, more.unwrap = FALSE)$learner.model,mdls_dir+target+"/"+target+"_lft_"+mean(lfts_vec,na.rm = T)+"_"+Sys.time())

###########################################
#--      SCORE CURRENT BASE             --#
###########################################


#-- Get scoring customer base dm
dm_score <- prepare_scoring_base(eop_score)

tmp = copy(dm_score)

#-- Add missing dummified columns
expectedColumns = mdl$features
missing_cols = setdiff(expectedColumns,names(dm_score))
for (nm in missing_cols) dm_score[,(nm):=0]

#-- Save the accounts
accounts_ids_score = dm_score$account_id

#-- Score
pred = predict(mdl, newdata = as.data.frame(dm_score[,..expectedColumns]))
pred = as.data.table(pred)[order(-prob.1)]
setnames(pred,"prob.1","pred_val")

#-- Assign Account IDs
pred[,Account_Id:=accounts_ids_score]

#-- Label with model ID
pred[,Model_Id:=model_id]


#-- Scope the customers who are eligible for the offer
#-- Those who have at least one Mobile postpaid are eligible
eligibleAccounts = dm_score[cnt_WIN_TV==0,account_id]
#-- Accounts who are not eligible, get a -1 score
pred[!(Account_Id %in% eligibleAccounts), pred_val:=-1]


min_score = min(pred[pred_val>-1,pred_val])
max_score = max(pred[pred_val>-1,pred_val])

#-- Scale scores
pred[pred_val>-1,Score:=100.0*(pred_val-min_score)/(max_score - min_score)]

#-- Assign score classes
cls = c("A","B","C","D","E")

pred[,Score_Class:="NA"]

#-- Get quantiles based on the length of scores
qnts = quantile(pred[!is.na(Score), Score], seq(0,1,length.out = length(cls)+1))

i=2
while(i<(2+length(cls)))
{
  
  pred[pred_val>-1 & Score <= as.numeric(qnts[i]) & Score_Class=="NA", Score_Class:=cls[ length(cls)- i +2]]
  i=i+1
}

#-- Load_Date
pred[,Load_Date:=format(Sys.Date(),"%d.%m.%Y")]


#-- Select cols
scores_to_write = pred[,.(Account_Id,Score,Score_Class,Model_Id,Load_Date)]


###########################################
#--      SAVE SCORES                    --#
###########################################

fwrite(scores_to_write,scores_dir+target+"/"+target+"_scores_"+Sys.Date()+".csv")

