#!/usr/bin/env bash

simdir="$SRC/strategy-sim"
expdir="$SRC/bitswap-tests"
while getopts "d:u:r:" opt; do
    case $opt in
        d)
            [[ -z "$OPTARG" ]] && usage && exit 1
            data="$OPTARG"
            ;;
        u)
            [[ -z "$OPTARG" ]] && usage && exit 1
            IFS=' ' read -r -a upload <<< "$OPTARG"
            ;;
        r)
            [[ -z "$OPTARG" ]] && usage && exit 1
            IFS=' ' read -r -a round_burst <<< "$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires and argument." >&2
            exit 1
            ;;
        --)
            break
            ;;
    esac
done
shift $((OPTIND-1))

cd "$simdir"
pipenv run main --data "$data" -u ${upload[*]} --dpr ${round_burst[*]} --outdir "$srcdir/results/sim"

cd "$srcdir"

# wenv cd bitswap-tests
# pipenv run main 

# cd "$srcdir"
