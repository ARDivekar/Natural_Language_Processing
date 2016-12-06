#Naive Bayes classifier.

#This classifier is trained on sentences which are tagged as very good, good, neutral, bad and very bad.
#Along with these class tags, also tagged are the words which are used to make this decision.

import pickle
import nltk
from article_manip import ArticleObject

from random import shuffle
from collections import defaultdict

with open("./all_sentences_shuffled.pickle", 'rb') as handle:
	all_sentences=pickle.load(handle)

class Training_set:
	def __init__(self, i, training):
		self.i=i
		self.training=training


with open("./training_set.pickle", 'rb') as handle:
	training_set_obj=pickle.load(handle)

i=training_set_obj.i
print "\n\tNumber of previously marked sentences: %s"%i
training=training_set_obj.training
'''
training={}
training[0]=[]
training[1]=[]
training[2]=[]
training[3]=[]
training[4]=[]
training[5]=[]

i=0
'''

while i<len(all_sentences):
	# print "\n\n\nRate the following sentence as (0=irrelevant, 1=very bad, 2=bad, 3=neutral, 4=good, 5=very good:\n"
	print "\n\n\nRate the sentence as: \n0=Cannot be rated due to insufficient data \n1=very bad \n2=bad \n3=neutral \n4=good \n5=very good:\n"
	print all_sentences[i]
	rating=raw_input('>')
	prev = i
	while(prev==i):
		try:
			rating  = int(rating)
			if rating != 0 and rating != 1 and rating != 2 and rating != 3 and rating != 4 and rating != 5:
				rating=raw_input("\nSorry, that is not a valid input. Try again: ")
			else:
				# print "rating:%s"%rating
				training[rating].append(all_sentences[i])
				i+=1
		except Exception:
			rating=raw_input("\nSorry, that is not a valid input. Try again: ")

	if(i%10==0):
		training_set_obj=Training_set(i,training)
		with open("./training_set.pickle", 'wb') as handle:
			pickle.dump(training_set_obj,handle)
		yorn=raw_input("\n\n\n\n\t\t<---EXIT?---> Y or N?\n\t\t>")
		if yorn.lower()=='y':
			# print training_set_obj.training
			print "\nNumber of marked sentences: %s"%training_set_obj.i
			exit()
