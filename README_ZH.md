# 使用deepspeed构建一个支持长文本的gemma-2b/7b

## README.md
- zh_CN [chinese](https://github.com/hhnqqq/GemmaLongText/blob/main/README_ZH.md)
- en [english](https://github.com/hhnqqq/GemmaLongText/blob/main/README.md)

### 环境配置
- 下载好预训练checkpoint: [gemma.ckpt](https://www.kaggle.com/models/google/gemma/frameworks/pyTorch)
- 准备一台有足够卡的服务器，我的配置是一台租用的8000服务器，cuda版本最好够新
- 推荐使用前配置好clash
- 安装本仓库的配置文件，会自动配置好依赖：python setup.py install
- 准备好长文本数据集

### 使用方法
- 选择使用的微调方法，lora/lora+/galore/全量
- 选择你使用的并行训练方法：pp/dp
- 根据本地条件编辑对应的脚本，如使用lora和pp时时编辑/scripts/pp_scrtpt/lora_train.sh
- 首先需要编辑base options中的设置
    - 替换data-path为你的数据集地址，数据集要求为jsonl格式，包含input、output两个键
    - 替换output-path为你的模型checkpoint保存地址
    - 替换ckpt-path为你的预训练模型地址
- 根据你的训练需求编辑options中的设置

```bash
#! /bin/bash
base_options="--data-path /workspace/longtext-2k-clean.jsonl \
--tokenizer-path /workspace/tokenizer.model \
--output-path /workspace/gemma/output \
--ckpt-path /workspace/gemma-2b-it.ckpt
"
options="$base_options \
    --experiment-name train_pi_test \
    --show-loss-step 1 \
    --epochs 3 \
    --batch-size-per-gpu 1 \
    --fp16 \
    --gradient-accumulation-steps 2 \
    --warmup 0.02 \
    --device cuda \
    --num-pp-stages 4 \
    --max-len 16384 \
    --max-src-len 16000 \
    --seed 42 \
    --read-nums 100 \
    --ds-config-path /workspace/gemma_long_rope/gemma/ds_config/pipeline.json \
    --variant 2b \
    --train-pi 2 \
    --lr 1e-5 \
    --warmup-min-lr 1e-6 \
    --warmup-max-lr 2e-5 \
    --use-lora-plus \
    --activation-checkpoint \
    --diy-optimizer \
    --atten-type flash_atten \
    "

run_cmd="deepspeed --include localhost:0,1,2,3 --master_port 16666 /workspace/gemma_long_rope/gemma/train.py ${options}"
echo ${run_cmd}
eval ${run_cmd}

set +x
```
### 新增特性支持
- 新增支持activation checkpoint
- 新增支持自定义optimizer
- 新增支持sat库中的lr scheduler
- 新增支持lora+ （给lora的两个参数矩阵A,B赋予不同的学习率，可以带来更好的性能表现，更快的收敛速度）
- 2024-03-20 新增支持[galore](https://github.com/jiaweizzhao/GaLore)(使用会出现梯度维度问题，待修改)
- 2024-03-21 新增支持torch的flash-attention实现
- 2024-03-21 新增支持纯dp训练
- 2024-03-23 新增支持lora-fa
- <b>2024-04-01 新增支持deepspeed-ulysses，能够训练更长的模型啦！！</b>
- 2024-04-02 新增DoRA支持

### TODO
- 支持更多的lora版本如plora
- 支持更多的长度外推方法
- 支持更多的memory efficient方法
- 以及更多的先进技术
- 完善scheduler的代码
- 加入对ring-attention的支持

### 感谢

感谢以下仓库的开源代码和模型权重：
- [sat](https://github.com/THUDM/SwissArmyTransformer)
- [gemma](https://github.com/google/gemma_pytorch)
- [loraplus](https://github.com/nikhil-ghosh-berkeley/loraplus)
- [chatglm-finetuning](https://github.com/liucongg/ChatGLM-Finetuning)
- 以及其他我参考借鉴的仓库

### 联系

欢迎使用以下方式联系我：
- 邮箱：hnhe@mail.ustc.edu.cn
- qq: 895228612