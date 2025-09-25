from espnet2.bin.s2t_inference_ctc import Speech2TextGreedySearch
import sys
import os

if len(sys.argv)!=4:
    sys.exit('%s <audio_list> <output_dir> <model>')

INPUT_LIST = sys.argv[1]
OUTPUT_DIR = sys.argv[2]
MODEL = sys.argv[3] # model_id e.g. "espnet/owsm_ctc_v3.1_1B"

f = open(INPUT_LIST, 'r')
audio_lst = f.read().split()
f.close()

#################
#
#  RECO
#
s2t = Speech2TextGreedySearch.from_pretrained(
    MODEL,
    device="cuda",
    use_flash_attn=False,   # set to True for better efficiency if flash attn is installed and dtype is float16 or bfloat16
    lang_sym='<eng>',
    task_sym='<asr>',
)

res = s2t.batch_decode(
    audio_lst,
    batch_size=4,
    context_len_in_secs=4,
)   # res is a list of str

#################
#
#  OUTP
#
for i, SPL in enumerate(audio_lst):
    # Cuidao amb el format ;)
    ODIR = OUTPUT_DIR + '/'  + '/'.join(SPL.split('/')[1:-1])
    NFILE = SPL.split('/')[-1][:-4] + '.txt'

    if not os.path.exists(ODIR):
        os.makedirs(ODIR)
        print("[ii] Folder %s created!" % ODIR)
    else:
        print("[ii] Folder %s already exists" % ODIR)

    with open(ODIR + '/' + NFILE, 'w') as f:
        f.write(res[i])
