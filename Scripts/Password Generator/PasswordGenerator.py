# Password Generator

# Combines two five letter words and two trailing digits.

from itertools import count
import random

with open("Scripts\Password Generator/fiveLetterWords.txt") as text:
    Word_List = text.readlines()
    Word_List = [word.strip() for word in Word_List] 

def Generate_Password() -> str: 
    Word_Choices = random.choices(Word_List, k=2)

    Pass_Text = "".join(Word_Choices)
    Password = f"{Pass_Text}{random.randint(10,99)}"
    return Password

def Check_Duplicates(input_list: list) -> bool:    
    unique = []
    duplicates = []
    for item in input_list:
        if item not in unique:
            unique.append(item)
        else:
            duplicates.append(item)
    if len(duplicates) == 0:
        return True
    else:
        return False    


Password_List = []
for i in range(5):
    Password_List.append(Generate_Password())

print(Check_Duplicates(Password_List))

