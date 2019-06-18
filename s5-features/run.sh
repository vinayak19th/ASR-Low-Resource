#!/bin/bash

# Copyright 2018 (author: Haris Bin Zia)
# Apache 2.0

. ./cmd.sh
[ -f path.sh ] && . ./path.sh
set -e

numLeavesTri1=2000
numGaussTri1=10000
numLeavesMLLT=2000
numGaussMLLT=10000
numLeavesSAT=2000
numGaussSAT=10000
numGaussUBM=400
numLeavesSGMM=7000
numGaussSGMM=9000

feats_nj=8
train_nj=8
decode_nj=8

echo ============================================================================
echo "                Data & Lexicon & Language Preparation                     "
echo ============================================================================

utils/fix_data_dir.sh data/train
utils/fix_data_dir.sh data/test

utils/prepare_lang.sh data/local/lang '<oov>' data/local data/lang

utils/format_lm.sh data/lang data/local/lm/trainlm.gz data/local/lang/lexicon.txt data/lang_test

#utils/format_lm.sh data/lang data/local/lm/bbclm.gz data/local/lang/lexicon.txt data/lang_test

echo ============================================================================
echo "         MFCC Feature Extration & CMVN for Training and Test set          "
echo ============================================================================

mfccdir=mfcc

steps/make_mfcc.sh --cmd "$train_cmd" --nj $feats_nj data/train exp/make_mfcc/train $mfccdir
steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir

steps/make_mfcc.sh --cmd "$train_cmd" --nj $feats_nj data/test exp/make_mfcc/test $mfccdir
steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test $mfccdir

utils/validate_data_dir.sh data/train
utils/fix_data_dir.sh data/train

utils/validate_data_dir.sh data/test
utils/fix_data_dir.sh data/test

echo ============================================================================
echo "                     MonoPhone Training & Decoding                        "
echo ============================================================================

steps/train_mono.sh  --nj "$train_nj" --cmd "$train_cmd" data/train data/lang exp/mono

utils/mkgraph.sh data/lang_test exp/mono exp/mono/graph

steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" \
 exp/mono/graph data/test exp/mono/decode

echo ============================================================================
echo "           tri1 : Deltas + Delta-Deltas Training & Decoding               "
echo ============================================================================

steps/align_si.sh --boost-silence 1.25 --nj "$train_nj" --cmd "$train_cmd" \
 data/train data/lang exp/mono exp/mono_ali

steps/train_deltas.sh --cmd "$train_cmd" \
 $numLeavesTri1 $numGaussTri1 data/train data/lang exp/mono_ali exp/tri1

utils/mkgraph.sh data/lang_test exp/tri1 exp/tri1/graph

steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" \
 exp/tri1/graph data/test exp/tri1/decode

echo ============================================================================
echo "                 tri2 : LDA + MLLT Training & Decoding                    "
echo ============================================================================

steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" \
  data/train data/lang exp/tri1 exp/tri1_ali

steps/train_lda_mllt.sh --cmd "$train_cmd" \
 $numLeavesMLLT $numGaussMLLT data/train data/lang exp/tri1_ali exp/tri2

utils/mkgraph.sh data/lang_test exp/tri2 exp/tri2/graph

steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" \
 exp/tri2/graph data/test exp/tri2/decode

echo ============================================================================
echo "              tri3 : LDA + MLLT + SAT Training & Decoding                 "
echo ============================================================================

steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" \
 --use-graphs true data/train data/lang exp/tri2 exp/tri2_ali

steps/train_sat.sh --cmd "$train_cmd" \
 $numLeavesSAT $numGaussSAT data/train data/lang exp/tri2_ali exp/tri3

utils/mkgraph.sh data/lang_test exp/tri3 exp/tri3/graph

steps/decode_fmllr.sh --nj "$decode_nj" --cmd "$decode_cmd" \
 exp/tri3/graph data/test exp/tri3/decode

echo ===========================================================================
echo "Finished Successfully"
echo ===========================================================================

