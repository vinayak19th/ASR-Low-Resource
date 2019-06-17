from trans_file import transString

words = open("/home/harsha/Downloads/words.txt", encoding='utf-8').read().splitlines()

trans = []
for i in range(len(words)):
    trans.append(transString(words[i]))

with open("~/Downloads/trans.txt", "w") as f:
    for j in range(len(trans)):
        f.write("{}\n".format(trans[j]))
    f.close()


