function rec --description "wf-recorder wrapper: bare -g uses slurp, -a monitor/monitorN/mic/micN"
    # Everything is passed through to wf-recorder, except:
    #   -g              (no value)  -> -g "$(slurp)"
    #   -a monitor                  -> default output's monitor (what you hear)
    #   -a monitor1, monitor2 ...   -> Nth output's monitor (see: rec -a list)
    #   -a mic                      -> default microphone
    #   -a mic1, mic2 ...           -> Nth microphone
    #   -a list                     -> show numbered devices and exit
    #   -q N                        -> compress with x264 CRF N (23 high, 28 balanced, 32 small)
    set -l sinks (pactl list short sinks | cut -f2)
    set -l mics (pactl list short sources | cut -f2 | string match -v '*.monitor')

    set -l args
    set -l i 1
    while test $i -le (count $argv)
        set -l a $argv[$i]
        set -l next
        test $i -lt (count $argv); and set next $argv[(math $i + 1)]

        switch $a
            case -g --geometry
                if test -z "$next"; or string match -q -- '-*' $next
                    set -l geom (slurp); or return 1
                    set -a args -g $geom
                else
                    set -a args -g $next
                    set i (math $i + 1)
                end

            case -a --audio
                set -l dev
                switch "$next"
                    case list
                        echo "Outputs (monitorN):"
                        for n in (seq (count $sinks)); echo "  monitor$n  $sinks[$n]"; end
                        echo "Mics (micN):"
                        for n in (seq (count $mics)); echo "  mic$n  $mics[$n]"; end
                        echo "Defaults: monitor = "(pactl get-default-sink)", mic = "(pactl get-default-source)
                        return 0
                    case monitor
                        set dev (pactl get-default-sink).monitor
                    case 'monitor*'
                        set -l n (string replace monitor '' -- $next)
                        set -q sinks[$n]; or begin; echo "rec: no $next (try: rec -a list)" >&2; return 1; end
                        set dev $sinks[$n].monitor
                    case mic
                        set dev (pactl get-default-source)
                    case 'mic*'
                        set -l n (string replace mic '' -- $next)
                        set -q mics[$n]; or begin; echo "rec: no $next (try: rec -a list)" >&2; return 1; end
                        set dev $mics[$n]
                end
                if test -n "$dev"
                    set -a args --audio=$dev
                    set i (math $i + 1)
                else
                    set -a args $a   # plain -a: wf-recorder's default device
                end

            case -q --quality
                # compress while recording: lower = better quality/bigger (23 high, 28 balanced, 32 small)
                set -a args -c libx264 -p crf=$next -p preset=veryfast
                set i (math $i + 1)

            case '*'
                set -a args $a
        end
        set i (math $i + 1)
    end

    wf-recorder $args
end
