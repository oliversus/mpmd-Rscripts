# R script to write taskfile for MPMD job on ECMWF supercomputer

# each MPMD job will be executed on an individual CPU on CRAY,
# thus each job needs an individual execution command

# individual log file for each CPU? True (T) or False (F)?
individual_logs = T

# read command arguments
args = commandArgs(trailingOnly = T)

# associate local variables with appropriate entries in argument vector
jobID      = args[2]
ndays      = args[3]
log_dir    = args[4]
cfg_dir    = args[5]
cfg_prefix = args[6]
cfg_suffix = args[7]
cfg_base   = args[8]
ksh_script = args[9]
cfg_attri  = args[10]
cfg_paths  = args[11]
out_name   = args[12]

# create vector containing MPMD task calls (one per day)
tasks = 1:ndays

# create MPMD task call for each day
for (i in 1:ndays){

   # convert single digit days to double digits
   i_dd = as.character(i)
   i_dd = ifelse(nchar(i_dd) == 1, paste("0", i_dd, sep=""), i_dd)

   # build config file name
   config_file = paste(cfg_dir, "/", cfg_prefix, cfg_base, i_dd, cfg_suffix, sep="")
   
   # build log file name
   log_file = paste(log_dir, "/log_mpmd_", cfg_base, i_dd, "_", jobID, ".txt", sep="")

   # concatenate elements to build task call
   tasks[i] = paste(ksh_script, " ", jobID, " ", cfg_attri, " ", cfg_paths, " ", config_file, sep="")
   
   # if individual log files should be written for each CPU, append output redirection to execution command
   tasks[i] = ifelse(individual_logs, paste(tasks[i], " > ", log_file, sep=""), tasks[i])

}

# write tasks vector to text file
out_name = paste(cfg_dir, "/MPMD_tasks_", cfg_base, jobID, ".txt", sep="")
write.table(tasks, file=out_name, quote=F, row.names=F, col.names=F)
