# Password Generator

# Combines two five letter words and two trailing digits.

import random

with open('./five', 'r') as text:
    Word_List = text.readlines()

print(type(Word_List))    