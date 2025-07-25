# LogHawk
Project 3 - Introducing LogHawk: a script-based log analysis tool designed to quickly scan logs for security threats, system errors, and unusual activity.
LogHawk can automatically scan for too many failed attempts, unusual traffic spikes, critical system errors, and suspicious script activity. By continuously scanning and flagging risky behavior, LogHawk helps teams respond faster, harden their systems, and stay ahead of attackers. There is also an experimental LogHawk file called "eLogHawk.sh", which is for monitoring logs automatically through file paths on Linux without having to manually move the file paths to another file. This is not yet in a fully functional state and is not intended for use currently. 



# Installation Steps 
LogHawk only utilizes bash, so there's no need to download any new compiler. 
Getting started with LogHawk is easy!
1. First, you need to have Python 3 installed. To do this, run "sudo apt-get install python3".
2. Then, download the main code from LogHawk.sh.
3. Open your Linux terminal and create a new file. This is done by typing "nano LogHawk.sh" and pasting all of the code from the main file.
4. Save this file and give it executable properties; this is done by typing "sudo chmod +x LogHawk.sh". Without this, the code cannot run.
5. Then go to the other script in this repo called LogHawk.txt, and copy this text. This is where you can decide what you would like for LogHawk to scan; the default is All.
6. Go back to your terminal and create a new file again with "nano LogHawk.txt", but this one does not have to be executable because it is just telling what LogHawk should scan.
7. If you would like LogHawk to be run automatically, you can set it as a cron script. This is done by going into the terminal and typing "crontab -e". This takes you to your cron scripts, then add "*/10 * * * * /bin/bash LogHawk.sh". This says you want LogHawk to run every 10 minutes. You can adjust the time to your preference.
8. To run this tool without cron, type "./LogHawk.sh" into your terminal. Once that's done, type "cat LogHawkAlerts.txt" which will show you all the alerts the tool found. 

# Preferences

- LogHawk sets up a new text file called "LogHawkAlerts.txt", which is where alerts from the script will be read. 
If you would like them to go to a different filepath, adjust the code at line 19 to your preferred filepath.
- To put your files for LogHawk to scan, simply replace the default logs on LogHawk.sh with the filepath of the log you want monitored.
    - To monitor a new filepath for failed passwords: adjust line 5
    - To monitor a new filepath for system errors: adjust line 7
    - To monitor a new filepath for suspicious cron jobs: adjust line 9
    - To monitor a new filepath for high traffic: adjust line 13
- If the cron scan is giving you too many false positives, you can add to the safe scripts on line 11, which tells LogHawk that those files are safe.
- You can adjust the threshold considered for IPs visiting your website by placing your new threshold on line 15; the default is 3.
- Following the LogHawk.txt, you can adjust what you would like to be monitored.
- You may also change the threshold for how many critical and error alerts signify a system failure alert. The default is 5 but can be adjusted on line 9.
