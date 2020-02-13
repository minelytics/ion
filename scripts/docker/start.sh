#!/bin/bash

APP_DIR=$(cd `dirname $0`/../../; pwd)
cd $APP_DIR
mkdir -p $APP_DIR/logs

export GOOS=linux

ISLB_PID_FILE=$APP_DIR/configs/islb.pid  #pid file, default: worker.pid

echo "stop islb process..."
if [ -f $ISLB_PID_FILE ]; then
	PID=`cat $ISLB_PID_FILE 2>/dev/null`
	if [ ! -n `cat $ISLB_PID_FILE` ]; then
	    echo "pid not exist"
	    exit 1;
	else
		SUB_PIDS=`pgrep -P $PID`
		if [ -n "$SUB_PIDS" ]; then
		    GRANDSON_PIDS=`pgrep -P $SUB_PIDS`
		fi
		echo "kill $PID $SUB_PIDS $GRANDSON_PIDS"
		kill $PID $SUB_PIDS $GRANDSON_PIDS
	fi
	rm -rf $ISLB_PID_FILE
fi
echo "finish islb stop process..."


ION_PID_FILE=$APP_DIR/configs/ion.pid  #pid file, default: worker.pid

echo "stop ion process..."

if [ -f $ISLB_PID_FILE ]; then
	PID=`cat $ION_PID_FILE 2>/dev/null`
	if [ ! -n "$PID" ]; then
	    echo "pid not exist"
	    exit 1;
	else 
		SUB_PIDS=`pgrep -P $PID`
		if [ -n "$SUB_PIDS" ]; then
		    GRANDSON_PIDS=`pgrep -P $SUB_PIDS`
		fi
		echo "kill $PID $SUB_PIDS $GRANDSON_PIDS"
		kill $PID $SUB_PIDS $GRANDSON_PIDS

	fi
	rm -rf $PID_FILE
fi
echo "finish ion stop process..."


WEB_PID_FILE=$APP_DIR/configs/node.pid  #pid file, default: node.pid

echo "stop web process..."
if [ -f $ISLB_PID_FILE ]; then
	PID=`cat $WEB_PID_FILE 2>/dev/null`
	if [ ! -n "$PID" ]; then
	    echo "pid not exist"
	    exit 1;
	else
		SUB_PIDS=`pgrep -P $PID`
		if [ -n "$SUB_PIDS" ]; then
		    GRANDSON_PIDS=`pgrep -P $SUB_PIDS`
		fi
		echo "kill $PID $SUB_PIDS $GRANDSON_PIDS"
		kill $PID $SUB_PIDS $GRANDSON_PIDS

	fi
fi
echo "finish web stop process..."



ISLB_EXE=islb
ISLB_COMMAND=$APP_DIR/bin/$ISLB_EXE
ISLB_CONFIG=$APP_DIR/configs/islb.toml
ISLB_PID_FILE=$APP_DIR/configs/islb.pid
ISLB_LOG_FILE=$APP_DIR/logs/islb.log

count=`ps -ef |grep " $ISLB_COMMAND " |grep -v "grep" |wc -l`
if [ 0 != $count ];then
    ps aux | grep " $ISLB_COMMAND " | grep -v "grep"
    echo "already start"
    exit 1;
fi

if [ ! -r $ISLB_CONFIG ]; then
    echo "$ISLB_CONFIG not exsist"
    exit 1;
fi

## build first
cd $APP_DIR/cmd/islb
go build -o $ISLB_COMMAND
cd $APP_DIR

## run command
echo "nohup $ISLB_COMMAND -c $ISLB_CONFIG >>$ISLB_LOG_FILE 2>&1 &"
nohup $ISLB_COMMAND -c $ISLB_CONFIG >>$ISLB_LOG_FILE 2>&1 &
pid=$!
echo "$pid" > $ISLB_PID_FILE
rpid=`ps aux | grep $pid |grep -v "grep" | awk '{print $2}'`
if [[ $pid != $rpid ]];then
	echo "start failly."
    rm  $ISLB_PID_FILE
	exit 1
fi



ION_EXE=ion
ION_COMMAND=$APP_DIR/bin/$ION_EXE
ION_CONFIG=$APP_DIR/configs/ion.toml
ION_PID_FILE=$APP_DIR/configs/ion.pid
ION_LOG_FILE=$APP_DIR/logs/ion.log

count=`ps -ef |grep " $ION_COMMAND " |grep -v "grep" |wc -l`
if [ 0 != $count ];then
    ps aux | grep " $ION_COMMAND " | grep -v "grep"
    echo "already start"
    exit 1;
fi

if [ ! -r $ION_CONFIG ]; then
    echo "$ION_CONFIG not exsist"
    exit 1;
fi

## build first
cd $APP_DIR/cmd/ion
go build -o $ION_COMMAND
cd $APP_DIR

## run command
echo "nohup $ION_COMMAND -c $ION_CONFIG >>$ION_LOG_FILE 2>&1 &"
nohup $ION_COMMAND -c $ION_CONFIG >>$ION_LOG_FILE 2>&1 &
pid=$!
echo "$pid" > $ION_PID_FILE
rpid=`ps aux | grep $pid |grep -v "grep" | awk '{print $2}'`
if [[ $pid != $rpid ]];then
	echo "start failly."
    rm  $ION_PID_FILE
	exit 1
fi


cd $APP_DIR/sdk/js
npm i
cd $APP_DIR/sdk/js/demo
npm i


nohup npm start 2>&1& echo $! > $APP_DIR/configs/node.pid






