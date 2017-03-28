#!/usr/bin/env bash

jid=$(ts bash -c "$(cat $1)")
ts -w $jid
