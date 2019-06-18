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

echo ============================================================================
echo "                        SGMM2 Training & Decoding                         "
echo ============================================================================

steps/align_fmllr.sh --nj "$train_nj" --cmd "$train_cmd" \
 data/train data/lang exp/tri3 exp/tri3_ali

steps/train_ubm.sh --cmd "$train_cmd" \
 $numGaussUBM data/train data/lang exp/tri3_ali exp/ubm4

steps/train_sgmm2.sh --cmd "$train_cmd" $numLeavesSGMM $numGaussSGMM \
 data/train data/lang exp/tri3_ali exp/ubm4/final.ubm exp/sgmm2_4

utils/mkgraph.sh data/lang_test exp/sgmm2_4 exp/sgmm2_4/graph

steps/decode_sgmm2.sh --nj "$decode_nj" --cmd "$decode_cmd"\
 --transform-dir exp/tri3/decode exp/sgmm2_4/graph data/test \
 exp/sgmm2_4/decode

echo ============================================================================
echo "                    MMI + SGMM2 Training & Decoding                       "
echo ============================================================================

steps/align_sgmm2.sh --nj "$train_nj" --cmd "$train_cmd" \
 --transform-dir exp/tri3_ali --use-graphs true --use-gselect true \
 data/train data/lang exp/sgmm2_4 exp/sgmm2_4_ali

steps/make_denlats_sgmm2.sh --nj "$train_nj" --sub-split "$train_nj" \
 --acwt 0.2 --lattice-beam 10.0 --beam 18.0 \
 --cmd "$decode_cmd" --transform-dir exp/tri3_ali \
 data/train data/lang exp/sgmm2_4_ali exp/sgmm2_4_denlats

steps/train_mmi_sgmm2.sh --acwt 0.2 --cmd "$decode_cmd" \
 --transform-dir exp/tri3_ali --boost 0.1 --drop-frames true \
 data/train data/lang exp/sgmm2_4_ali exp/sgmm2_4_denlats exp/sgmm2_4_mmi_b0.1

for iter in 1 2 3 4; do
  steps/decode_sgmm2_rescore.sh --cmd "$decode_cmd" --iter $iter \
   --transform-dir exp/tri3/decode data/lang_test data/test \
   exp/sgmm2_4/decode exp/sgmm2_4_mmi_b0.1/decode_it$iter
done

echo ============================================================================
echo "               DNN Hybrid Training & Decoding (Karel's recipe)            "
echo ============================================================================

local/nnet/run_dnn.sh

echo ============================================================================
echo "Finished Successfully"
echo ============================================================================

exit 0
