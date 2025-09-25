import os
import sys

import torch
#from espnet2.bin.s2t_inference_ctc import Speech2TextGreedySearch
#from espnet2.bin.s2t_inference_ctc_jsj import Speech2TextGreedySearch
from espnet2.bin.s2t_inference_ctc_jsj_falseStreaming import Speech2TextGreedySearch
from espnet2.layers.create_adapter_fn import create_lora_adapter
import espnetez as ez

if len(sys.argv)!=11:
    sys.exit('%s <audio_path> <chkp_path:path/to/5epoch.pth> <odir_adapt_samples> <odir_hyp> <model> <lora_rank> <lora_alpha> <context_len> <context_left> <context_right>')
    
AUDIO_PATH = sys.argv[1]
CHKP_PATH = sys.argv[2]
ODIR_ADAPT = sys.argv[3]
ODIR_HYP = sys.argv[4]
MODEL = sys.argv[5]
LORA_RANK=int(sys.argv[6])
LORA_ALPHA=int(sys.argv[7])
CONTEXT = float(sys.argv[8])
CONLEFT = float(sys.argv[9])
CONRIGHT = float(sys.argv[10])

EPOCH_NUM = CHKP_PATH.split('/')[-1].split('epoch')[0]


LORA_TARGET = [
    "linear_q", "linear_v"
]

# Load original model
print("[ii] Loading original model")
model = Speech2TextGreedySearch.from_pretrained(
    MODEL,
    device="cuda",
    use_flash_attn=False,   # set to True for better efficiency if flash attn is installed and dtype is float16 or bfloat16
    lang_sym='<eng>',
    task_sym='<asr>',
)
# Apply LoRA
print("[ii] Applying adapter")
create_lora_adapter(model.s2t_model, rank=LORA_RANK, alpha=LORA_ALPHA, dropout_rate=0.1, target_modules=LORA_TARGET)
model.s2t_model.train()
# TODO
# ES IMPORTANTISIM FICAR EL TRAIN DESPRES DE CARREGAR PER A FER EL MERGE
# TODO
#print(model.s2t_model.encoder.encoders[0].attn.linear_q.lora_A)
d = torch.load(CHKP_PATH)
model.s2t_model.load_state_dict(d, strict=False)
# TODO
# ES IMPORTANTISIM FICAR EL EVAL DESPRES DE CARREGAR PER A FER EL MERGE
# TODO
model.s2t_model.eval()
#print(model.s2t_model.encoder.encoders[0].attn.linear_q.lora_A)

print("[ii] Start inference")
hyp, adapt_spl = model.batch_decode(
    [AUDIO_PATH],
    batch_size=4,
    context_len_in_secs=CONTEXT,
    context_right=CONRIGHT,
    context_left=CONLEFT,
)   # res is a list of str


if not os.path.exists(ODIR_HYP):
    os.makedirs(ODIR_HYP)
NFILE = AUDIO_PATH.split('/')[-1][:-4] + f".ep{EPOCH_NUM}.txt"
with open(ODIR_HYP + '/' + NFILE, 'w') as f:
    f.write(hyp[0])

for i, SPL in enumerate(adapt_spl):
    # Cuidao amb el format ;)
    ODIR = ODIR_ADAPT + '/'  + '/'.join(AUDIO_PATH.split('/')[1:])[:-4]
    NFILE = AUDIO_PATH.split('/')[-1][:-4] + '-{:03d}.txt'.format(i)

    if not os.path.exists(ODIR):
        os.makedirs(ODIR)
        print("[ii] Folder %s created!" % ODIR)

    with open(ODIR + '/' + NFILE, 'w') as f:
        f.write(SPL)

