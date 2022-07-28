# Password Generator

# Combines two five letter words and two trailing digits.

# Imports
import random

# Open Word List
with open("Scripts\Password Generator/fiveLetterWords.txt") as text:
    Word_List = text.readlines()
    Word_List = [word.strip() for word in Word_List] 

# Function - generates password by joining two random 5 letter words and a 2 digit number
def Generate_Password() -> str: 
    Word_Choices = random.choices(Word_List, k=2)

    Pass_Text = "".join(Word_Choices)
    Password = f"{Pass_Text}{random.randint(10,99)}"
    return Password

# Checks password list for duplicate entries. Outputs True is the list contains only unique values.
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


# Set password list variable
Password_List = []
# Get number of passwords to generate
Password_Range = int(input("Please specify the number of passwords to be generated: "))

# Generate passwords 
for i in range(Password_Range):
    Password_List.append(Generate_Password() + "\n")

# Check for duplicates and print result
List_Valid = Check_Duplicates(Password_List)
print(List_Valid)

# If list contains only unique passwords, output to .txt file (Caution - Overwrites)
if List_Valid:
    with open("Scripts\Password Generator/passwords.txt", "w") as output_file:
        output_file.writelines(Password_List)

