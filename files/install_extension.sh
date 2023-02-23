#!/bin/bash
source /root/.phpbrew/bashrc
phpbrew use $1
phpbrew ext install $2 $3
phpbrew off