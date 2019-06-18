# Sunshine
*Vernacular Language trigger word detector*

## Background & Proposal

Propose Components :
1. [PyTorch](https://pytorch.org/)
2. [Kaldi](http://kaldi-asr.org/doc/index.html)
3. Misc NLP library for string matching
4. Possible extension using pretrained language models to perform further language inference


Initital Protoype and Discussion
>Basic Kaldi Architecture
> ![KALDI](Literature/discussion.png)


### Resources for Specific Questions

* [Kaldi for Dummies](
https://kaldi-asr.org/doc/kaldi_for_dummies.html#kaldi_for_dummies_environment)

* [Kaldi Lattices](https://kaldi-asr.org/doc/lattices.html)

* [Presentation](https://myelinf-my.sharepoint.com/:p:/g/personal/harsha_myelinfoundry_com/ER5nsCVZz4RMjNno_vHYLL4BXlVEqsBVWWP9Un5SrEK17g?e=4cbA8W)

### Repositories for Reference
* [Kaldi Pytorch](https://github.com/mravanelli/pytorch-kaldi#overview-of-the-toolkit-architecture)

* [Recipe for Kaldi-Arabic](http://alt.qcri.org//resources/speech/)

* [EspNet](https://github.com/espnet/espnet)

* [Kaldi-ASR](https://github.com/kaldi-asr/kaldi)

* [Nabu](https://github.com/vrenkens/nabu)

### Proposed Languages with dataset used
* [Pashto](https://catalog.ldc.upenn.edu/LDC2016S09)
* [Urdu](Some University)


#### Alternative Approaches: 
1. [Mozilla DeepSpeech](https://github.com/mozilla/DeepSpeech)
2. [Wav2Letter++](https://github.com/facebookresearch/wav2letter)

### Tasks 

- [x] Acquire Dataset
- [x] Test PyTorch Kaldi
- [x] Form Recipe
- [ ] Train PyTorch Kaldi
- [ ] Test Model on Real Time Data

# Procedure 

### Data Preparation:
**Refer to __Kaldi Documentation__ for any clarifications: http://kaldi-asr.org/doc/data_prep.html**

1. Creating the data/train directory required the creating of 3 files manually:
    * __text.txt__ - Contains the transcript indexed by utterance ID's. 
    * __wav.scp__ - Contains all the full paths of all the wav audio files indexed by utterance ID's. **Make sure to edit this file before use to match your input files**
    * __utt2spk__ - Contains the utterance ID's matched to the speaker ID's.
>Example Train folder - [data/train](s5/data/train) 
 2. Make sure all the files are in __sorted order__ for kaldi f0r alignment computations.
3. Create a test folder with the appropriate train-test split.  
>Example Test folder - [data/test](s5/data/test)
4. To create the [data/local/lang](s5/data/local/lang) directory the following files are needed:
    * __lexicon.txt__: Contains the Grapheme-Phoneme relationships
    * __silence_phones.txt__: Contains the silence markers
    * __nonsilence_phones.txt__: Contains all the other graphemes.
    * __extra_questions.txt__: Just an empty file
5. Run the [run.sh](s5/run.sh) script's first section - Data & Lexicon & Language Preparation to create the remaining parts of the recipe for pre-processing.

### Training the Model:
**Refer to Pytorch Kaldi-Repository documentation for any clarifications: https://github.com/mravanelli/pytorch-kaldi#overview-of-the-toolkit-architecture**

1. Run the remaining sections of the [run.sh](s5/run.sh) script to compute the [mfcc vectors](#mfcc)


# Theory:
<a id=i-vect></a>
 * __I-Vectors__: The word i-vector stands for "identity i-vector". It allows to compute an utterance model (a vector) using the corresponding MFCC features. This is done using a technique called Factor analysis which computes 0th and 1st order statistics of a set of featres over a generic model (a mixture of Gaussians) called world model or universal background model UBM, then computes the corresponding i-vector. Roughly, the UBM descibes what the average distribution of "speech" looks like and i-vectors allow to have a representation of a speech utterance that is "relative" to that generic model. [link](https://www.researchgate.net/post/Can_someone_introduce_me_to_i_vector_approach_for_speaker_recognition)

<a id=mfcc></a>
* __MFCC Feature__: Mel-frequency cepstral coefficients (MFCCs) are coefficients that collectively make up an MFC[1]. They are derived from a type of cepstral representation of the audio clip (a nonlinear "spectrum-of-a-spectrum"). The difference between the cepstrum and the mel-frequency cepstrum is that in the MFC, the frequency bands are equally spaced on the mel scale, which approximates the human auditory system's response more closely than the linearly-spaced frequency bands used in the normal cepstrum. This frequency warping can allow for better representation of sound, for example, in audio compression. [link](https://en.wikipedia.org/wiki/Mel-frequency_cepstrum)
