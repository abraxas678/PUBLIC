 #!/bin/bash                                                                                                                       
                                                                                                                                   
 # Set the path to your Git repository                                                                                             
 REPO_PATH=/home/abrax/tmp/public/splitter
                                                                                                                                   
 # Navigate to the directory containing the file                                                                                   
 cd "$REPO_PATH"                                                                                                                   
                                                                                                                                   
 # Use Git log to get the last three commits that modified 1.sh                                                                    
 COMMIT_LOG=$(git log -n 3 --pretty=format:"%H" --since=yesterday -- 1.sh)                                                         
                                                                                                                                   
 # Loop through each commit and print the corresponding version of 1.sh                                                            
 for COMMIT in $COMMIT_LOG; do                                                                                                     
   git show "$COMMIT":1.sh | head -n 10                                                                                            
 done 
