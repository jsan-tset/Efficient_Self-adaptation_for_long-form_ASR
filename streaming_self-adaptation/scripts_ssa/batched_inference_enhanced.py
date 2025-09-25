from espnet2.bin.s2t_inference_ctc_mod import Speech2TextGreedySearch
import sys
import os

if len(sys.argv)!=8:
    sys.exit('%s <audio_path> <odir_adapt_samples> <odir_hyp> <model> <context_len> <context_left> <context_right>')
    
AUDIO_PATH = sys.argv[1]
ODIR_ADAPT = sys.argv[2]
ODIR_HYP = sys.argv[3]
MODEL = sys.argv[4]
CONTEXT = float(sys.argv[5])
CONLEFT = float(sys.argv[6])
CONRIGHT = float(sys.argv[7])

#################
#
#  RECO
#
model = Speech2TextGreedySearch.from_pretrained(
    MODEL,
    device="cuda",
    use_flash_attn=False,   # set to True for better efficiency if flash attn is installed and dtype is float16 or bfloat16
    lang_sym='<eng>',
    task_sym='<asr>',
)

model.s2t_model.eval()

hyp, adapt_spl = model.batch_decode(
    [AUDIO_PATH],
    batch_size=4,
    context_len_in_secs=CONTEXT,
    context_right=CONRIGHT,
    context_left=CONLEFT,
)   # res is a list of str

#################
#
#  OUTP
#

if not os.path.exists(ODIR_HYP):
    os.makedirs(ODIR_HYP)
NFILE = AUDIO_PATH.split('/')[-1][:-4] + '.txt'
with open(ODIR_HYP + '/' + NFILE, 'w') as f:
    f.write(hyp[0])

for i, SPL in enumerate(adapt_spl):
    NFILE = AUDIO_PATH.split('/')[-1][:-4] + '-{:03d}.txt'.format(i)
    ODIR = ODIR_ADAPT + '/'  + '/'.join(AUDIO_PATH.split('/')[1:])[:-4]

    if not os.path.exists(ODIR):
        os.makedirs(ODIR)
        print("[ii] Folder %s created!" % ODIR)

    with open(ODIR + '/' + NFILE, 'w') as f:
        f.write(SPL)
