##Requires command line package https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
## AWS CLI V2 has Python embedded into it so you shouldn't have to install..... https://www.simplified.guide/aws/cli/install-on-pip
##Requires setting up Config file and Credentials file
##Log on to AWS S3, Access Portal, click on Access Key link under prod. Get credentials for databay-s3-viewer-permission-set
##Step 1: run in terminal tab....
###aws configure sso --profile [enter-your-profile-name-here]
####copy SSO start URL, SSO Region, hit enter when asks for default output format
#### Follow instructions for validating SSO authorization page, confirm the codes match,
# hit enter than click on grant access
##Log on to AWS S3, Get credentials for databay-s3-viewer-permission-set, and retrieve aws_access_key_id and aws_secret_access_key
###aws configure --profile [enter-your-profile-name-here]
##copy AWS access key ID into AWS Access Key ID [None]:
##copy AWS secret access key into AWS Secret Access Key [None]:
##copy SSO Region into Default region name [None]:
##hit enter without entering anything into Default output format [None]:
##follow instructions
##Reference: https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-files.html

library('stringr')
library('glue')

##Reset SSO Tokens 
system("aws sso login")

Sys.setenv(AWS_DEFAULT_PROFILE="my-sso")
#system("set AWS_DEFAULT_PROFILE=my-sso")
##Check settings ...... 
system("aws configure list")

##fields that can be set based on globals in your master file.
registry <- "'ADASANDBOX-ZEL/"
datefolder <- "20241106'"
prefixname <- paste0(registry,datefolder)
#prefixname <- "'ADASANDBOX-ZEL/20241009'"
profilename <- "my-sso"
delim=glue(" \"/\" ")
delim


##Code that exports the data based on global parameters from R and aws CLI
#mystr=paste("aws s3api list-objects-v2 --profile",profilename,"--bucket corevitas-data-bay --delimiter '/' --prefix", prefixname, "--query CommonPrefixes --output text")
###Set the connection string to pull the full folder name for the date we are looking at
mystr=paste("aws s3api list-objects-v2 --profile",profilename,"--bucket corevitas-data-bay --delimiter",delim,"--prefix", prefixname, "--query CommonPrefixes --output text")
aws s3api list-objects-v2 --profile my-sso --bucket corevitas-data-bay --delimiter",delim,"--prefix", prefixname, "--query CommonPrefixes --output text
folderAWS <- system(mystr, intern = TRUE)
folderAWS

  ###Export data from the Date-TimeStamp folder we found in the section above
  ### ****Requires a folder of /data  in your current working directory****
  mystr2=paste0("aws s3 cp s3://corevitas-data-bay/",folderAWS,"raw"," ./data --recursive --profile ",profilename)
  mystr2
  system(mystr2)


