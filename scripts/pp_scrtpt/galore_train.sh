#! /bin/bash
base_options="--data-path /workspace/longtext-2k-clean.jsonl \
--tokenizer-path /workspace/tokenizer.model \
--output-path /workspace/gemma/output \
--ckpt-path /workspace/gemma-2b-it.ckpt
"

disable_list=("embedder","mlp")

options="$base_options \
    --experiment-name train_pi_test \
    --show-loss-step 1 \
    --epochs 3 \
    --batch-size-per-gpu 1 \
    --fp16 \
    --gradient-accumulation-steps 2 \
    --warmup 0.02 \
    --device cuda \
    --num-stages 1 \
    --max-len 1024 \
    --max-src-len 512 \
    --seed 42 \
    --read-nums 100 \
    --ds-config-path /workspace/gemma_long_rope/gemma/ds_config/pineline.json \
    --variant 2b \
    --train-pi 2 \
    --lr 1e-5 \
    --warmup-min-lr 1e-6 \
    --warmup-max-lr 2e-5 \
    --diy-optimizer \
    --use-galore \
    --optim-type galore_adamw8bit \
    --activation-checkpoint \
    --disable-list \
    "

for item in "${disable_list[@]}"; do
    options+=" \"$item\""
done

run_cmd="deepspeed --include localhost:0 --master_port 16666 /workspace/gemma_long_rope/train/pp_train.py ${options}"
echo ${run_cmd}
eval ${run_cmd}

set +x