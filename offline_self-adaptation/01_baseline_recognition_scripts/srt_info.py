import os.path
import srt
import sys

if len(sys.argv) != 2:
    sys.exit(f"{sys.argv[0]} <srt>")

fn = sys.argv[1]
name = os.path.splitext(os.path.basename(fn))[0]

data = open(fn).read()

for sub in srt.parse(data):
    start = sub.start.total_seconds()
    end = sub.end.total_seconds()
    txt = ' '.join(sub.content.split())
    if end-start >= 2.0:
        print(f"{name}_{sub.index} {start} {end} {txt}")
