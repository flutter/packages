if [ $# -eq 0 ]; then
  echo "usage: run.sh [android | ios]"
fi

pub run imitation_game --platform=$1
