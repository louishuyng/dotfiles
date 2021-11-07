#!/bin/bash

PRE_MARKET_START=0430
MARKET_START=0930
MARKET_END=1600
AFTER_MARKET_END=2000
CURRENT_TIME=$(date +%H%M)

if [[ 
  $(date +%u) -gt 5 
  || ${CURRENT_TIME#0} -gt ${AFTER_MARKET_END#0}
  || ${CURRENT_TIME#0} -lt ${PRE_MARKET_START#0}
]]; then
  sketchybar -m set vti drawing off
  exit 0
fi

if [[ 
  ${CURRENT_TIME#0} -ge ${MARKET_START#0}
  && ${CURRENT_TIME#0} -le ${MARKET_END} 
]]; then
  VTI=$(curl -s -L https://robinhood.com/stocks/VTI \
  | grep -E -o '[\+|\-]\d{1,4}\.\d{1,2}%' | head -n 1)
  echo 2
elif [[ 
  (${CURRENT_TIME#0} -ge ${PRE_MARKET_START#0}
  && ${CURRENT_TIME#0} -lt ${MARKET_START#0})
  || (${CURRENT_TIME#0} -gt ${MARKET_END#0}
  && ${CURRENT_TIME#0} -le ${AFTER_MARKET_END#0}) 
]]; then
  VTI=$(curl -s -L https://robinhood.com/stocks/VTI \
  | grep -E -o '[\+|\-]\d{1,4}\.\d{1,2}%' | head -n 1)
  echo 3
fi

[[ $VTI == "" ]] && exit 0 || :

sketchybar -m set vti label $VTI
sketchybar -m set vti drawing on

