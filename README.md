# Sunshine
Vernacular Language trigger word detector


Propose Components :
1. PyTorch
2. Kaldi
3. Misc NLP library for string matching. (TBD)
4. Possible extension using BERT to perform further language inference


Initital Protoype and Discussion
> ![Prototype for ](discussion.png)


### Resources for Specific Questions
I Vectors
https://www.researchgate.net/post/Can_someone_introduce_me_to_i_vector_approach_for_speaker_recognition

Kaldi for Dummies
https://kaldi-asr.org/doc/kaldi_for_dummies.html#kaldi_for_dummies_environment

Kaldi Lattices
https://kaldi-asr.org/doc/lattices.html


Presentation
https://myelinf-my.sharepoint.com/:p:/g/personal/harsha_myelinfoundry_com/ER5nsCVZz4RMjNno_vHYLL4BXlVEqsBVWWP9Un5SrEK17g?e=4cbA8W

### Repositories for Reference
Kaldi Pytorch : https://github.com/mravanelli/pytorch-kaldi#overview-of-the-toolkit-architecture

Recipe for Kaldi-Arabic : http://alt.qcri.org//resources/speech/

EspNet : https://github.com/espnet/espnet

Kaldi-ASR : https://github.com/kaldi-asr/kaldi

Nabu : https://github.com/vrenkens/nabu

### Dataset
https://catalog.ldc.upenn.edu/LDC2016S09 (Currently being purchased) 
https://archive.org/details/ArabicEnglishPashtoQaziFazlUllah


#### Alternative Approaches: 
1. https://github.com/mozilla/DeepSpeech

### Tasks 

- [x] Acquire Dataset
- [x] Test PyTorch Kaldi
- [ ] Form Recipe
- [ ] Test EspNet
- [ ] Train Kaldi/EspNet to Convergence on Data
- [ ] Test Model on Real Time Data
