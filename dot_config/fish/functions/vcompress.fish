function vcompress --description "Compress a video: vcompress FILE [CRF=28]"
    # Lower CRF = better quality/bigger (23 high, 28 balanced, 32 small)
    if not test -f "$argv[1]"
        echo "Usage: vcompress FILE [CRF=28]" >&2
        return 1
    end
    set -l in $argv[1]
    set -l crf 28
    set -q argv[2]; and set crf $argv[2]
    set -l out (string replace -r '\.[^.]+$' '' -- $in)_small.mp4

    ffmpeg -y -hide_banner -loglevel error -stats -i $in \
        -c:v libx264 -crf $crf -preset medium -pix_fmt yuv420p \
        -c:a aac -b:a 128k -movflags +faststart $out
    or return 1

    echo (du -h $in | cut -f1)" → "(du -h $out | cut -f1)"   $out"
end
