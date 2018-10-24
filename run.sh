#!/usr/bin/env bash

usage="\
usage: run.sh [-h] -d FILESIZE -u [UPLOAD_RATE [UPLOAD_RATE ...]]
              -r ROUND_BURST [-k {sim,exp,both}]"

srcdir="$(dirname $(readlink -f $0))"
simdir="$SRC/strategy-sim"
expdir="$SRC/bitswap-tests"

kind='both'
while getopts "d:u:r:k:h" opt; do
    case $opt in
        d)
            data="$OPTARG"
            ;;
        u)
            IFS=' ' read -r -a upload <<< "$OPTARG"
            ;;
        r)
            IFS=' ' read -r -a round_burst <<< "$OPTARG"
            ;;
        k)
            kind="$OPTARG"
            ;;
        h)
            echo "$usage"
            exit 0
            ;;
        *)
            echo "$usage" >&2
            exit 1
            ;;
        --)
            break
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z "${data}" || -z "${upload[@]}" || -z "${round_burst[@]}" ]]; then
    echo "missing required argument(s)" >&2
    echo "$usage" >&2
    exit 1
fi

if [[ "$kind" == 'sim' || "$kind" == 'both' ]]; then
    cd "$simdir"
    echo "running simulation..."
    pipenv run main \
        --data "$data" \
        -u ${upload[*]} \
        --dpr ${round_burst[*]} \
        --outdir "$srcdir/results/sim" &
    cd "$srcdir"
fi

if [[ "$kind" == 'exp' || "$kind" == 'both' ]]; then
    cd "$expdir"
    echo "running experiment..."
    outfile=$(./test.sh \
        -t 2 \
        -n 3 \
        -s "identity" \
        -f "head -c $data /dev/urandom" \
        -b "${upload[*]}" \
        -r "${round_burst[*]}" \
        -d "$srcdir/results/exp" \
      | grep -oP "Saved results to: \K.*?$")

    cd plot
    pipenv run main "$outfile" &

    cd "$srcdir"
fi
