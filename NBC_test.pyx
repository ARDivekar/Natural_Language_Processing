import pickle
import nltk
from collections import defaultdict
from random import randrange
from math import log
# from NBC_train import Training_set


def make_NGRAMS(n, text): 
	# n is the MAX gram depth
	# assume 'text' is a list of words
	Grams={}
	for i in range(1,n+1): # i is the gram-depth, i.e. unigrams, bigrams, trigrams, quadrigrams etc.
		
		Grams[i]=defaultdict(int)  # dict of tuples, where each tuple is a key for its correpsonding occurence count.
		# eg: Grams[4] = {('I', 'want', 'some', 'chinese'): 14, ('hello', ',', 'can', 'you'): 8)}
		for j in range(i, len(text)):
			last_i_words=[]
			for k in range(0,i):
				last_i_words.append(text[j-i+k])
			last_i_words=tuple(last_i_words)  # to be used as a key for dictionary Grams[i]
			Grams[i][last_i_words]=Grams[i][last_i_words]+1
	return Grams



class Training_set:
	def __init__(self, i, training):
		self.i=i
		self.training=training

with open("./all_sentences_shuffled.pickle", 'rb') as handle:
	all_sentences=pickle.load(handle)

with open("./training_set.pickle", 'rb') as handle:
	training_set_obj=pickle.load(handle)

i=training_set_obj.i
print "\n\tNumber of marked sentences: %s"%i
training=training_set_obj.training
# for i in training:
# 	print "%s : %s"%(i,len(training[i]))


N=int(raw_input("\nEnter N:\n>"))

def NB_preprocess():
	d=5



vocab=[]
classes_len={}  #the total number of words in each class
classes_len[0]=0
classes_len[1]=0
classes_len[2]=0
classes_len[3]=0
classes_len[4]=0
classes_len[5]=0

classes={}   #a lot of data about each class
# classes[0]=defaultdict(int)
# classes[1]=defaultdict(int)
# classes[2]=defaultdict(int)
# classes[3]=defaultdict(int)
# classes[4]=defaultdict(int)
# classes[5]=defaultdict(int)

mega_docs=defaultdict(lambda:[])
classes_grams={}

for x in training: #training is a dictionary of all the sentences in that class
	for y in training[x]:
		words=nltk.word_tokenize(y)
		vocab+=words
		classes_len[x]+=len(words)
		mega_docs[x]+=(words)

		# for z in words:
		# 	classes[x][z]+=1  #the unigram counts of the classes
	classes_grams[x]=make_NGRAMS(N, mega_docs[x])


#classes_grams is a dictionary of dictionaries of dictionaries.
#Top level: for each class, we have a dictionary of N-Grams for the sentences in that class.
#2nd level: inside each of these dictionaries, we index by the 'N' of N-gram, to get a dictionary of counts of that N-gram model.
#3rd level: at this level, we index by unigrams, bigrams, trigrams etc, to get their counts.


vocab=set(vocab)

print "vocab size:%s"%len(vocab)
# for x in classes_len:
# 	print "Class %s : Number of words = %s, Number of unique words = %s"%(x,classes_len[x], len(classes[x]))




def len_unigrams_to_ngrams(number_of_unigrams, N):
	return number_of_unigrams-N+1


def NBclassify_Ngrams(training, classes_grams, classes_len, sentence, N):
	vocabs=defaultdict(lambda:[])  #vocabulary for unigrams, bigrams etc.
	for _class_ in classes_grams: 
		for n in classes_grams[_class_]:  #n for the gram value
			vocabs[n]+=list(set(classes_grams[_class_][n]))
			vocabs[n]=list(set(vocabs[n]))
	vocab_sizes={}	
	for n in vocabs:
		vocab_sizes[n]=len(vocabs[n])
		# print vocab_sizes[n]


	priors={}
	total=0  #total number of documents (i.e. sentences)
	for x in training:
		total+=len(training[x])
		priors[x]=len(training[x])

	probabilities={}
	for x in training:
		probabilities[x]=log(float(priors[x])/total)

	words=nltk.word_tokenize(sentence)
	gram_depth=len(classes_grams[0])
	words_gram=make_NGRAMS(gram_depth, words)
	# for i in words_gram:
	# 	print "WORDSGRAM", i
	# 	print words_gram[i]
	#N=2 #we only consider bigrams for now
	for x in range(0,6):
		for i in words_gram[N]: 
			count_in_class=classes_grams[x][N][i]
			probabilities[x]+=log(count_in_class + 1) - log(len_unigrams_to_ngrams(classes_len[x], N) + vocab_sizes[N] + 1)
	for x in probabilities:
		print x,":",probabilities[x]
	selected_class=0
	for x in range(1,6):
		if probabilities[x]>probabilities[selected_class]:
			selected_class=x
	list_of_classes={0:"Irrelevant", 1:"Very bad", 2:"Bad", 3:"Neutral", 4:"Good", 5:"Very Good"}
	print "selected_class: %s"%selected_class, list_of_classes[selected_class]

	print "\nWas this the right class?"
	correct_class=int(raw_input("\nEnter what you think was the right category:\n>"))



'''
def NBclassify(vocab, training, classes_len, classes, sentence):
	vocab_size=len(vocab)
	priors={}
	total=0  #total number of documents (i.e. sentences)
	for x in training:
		total+=len(training[x])
		priors[x]=len(training[x])

	probabilities={}
	for x in training:
		probabilities[x]=log(float(priors[x])/total)

	words=nltk.word_tokenize(sentence)
	for word in words:
		for x in range(0, 6) : #classes 0 upto 5
			count_in_class=classes[x][word]  #since all classes[x] are defaultdicts, if word does not occur, then it defaults to zero
			probabilities[x]+=log(count_in_class +1) - log(classes_len[x]+ vocab_size+1)  #unknowns are considered
			# probabilities[x]-=log(classes_len[x]/100)
	for x in probabilities:
		print x,":",probabilities[x]
	selected_class=0
	for x in range(1,6):
		if probabilities[x]>probabilities[selected_class]:
			selected_class=x
	print "selected_class: %s"%selected_class

'''


sentence=all_sentences[randrange(i+1,len(all_sentences))]
print sentence
# NBclassify(vocab, training, classes_len, classes, sentence)
NBclassify_Ngrams(training, classes_grams, classes_len, sentence,N)